(import spork/path)

# tppd — render tpp-templated dotfiles from $FLAKE/home into $HOME.
#
# Invoked only by the nix config: once on activation (full render), and via a
# watchexec user service as `tppd --daemon` (render the reported change set,
# falling back to a full render when it can't be resolved).
#
# The render manifest ($FLAKE/home/tppd.jdn) is a Janet data file, parsed directly.
#
# Every write is guarded and atomic: render to a temp file in the destination
# directory, and only replace the target when tpp succeeded AND the output
# differs, so a failed render or a no-op never disturbs the target (or its
# mtime, which config-watchers key off).

(def HOME (os/getenv "HOME"))
(def FLAKE (or (os/getenv "FLAKE") (string HOME "/.config/nix")))
(def HOME-DIR (string FLAKE "/home"))
(def MANIFEST (string FLAKE "/home/tppd.jdn"))

(def uname (if (= :macos (os/which)) "Darwin" "Linux"))  # -> tpp
(def os-tok (string/ascii-lower uname))                  # darwin | linux, for the manifest

(defn- capture [args]
  "Run a command, returning its stdout as a string; errors if it fails."
  (with [out (file/temp)]
    (def code (os/execute args :p {:out out}))
    (unless (zero? code) (errorf "command failed (%d): %j" code args))
    (file/seek out :set 0)
    (string (or (:read out :all) ""))))

(def hostname
  (or (os/getenv "HOST")
      (string/trim (capture ["uname" "-n"]))))

(def threads (os/cpu-count))  # logical CPUs on the host -> tpp

(def manifest (parse (string (slurp MANIFEST))))  # slurp yields a buffer

(defn- dest-for [entry]
  "Destination for this entry on the current OS, or nil to skip."
  (cond
    (string? entry) entry
    (dictionary? entry) (get entry (keyword os-tok))
    nil))

(defn- mode [p] (try (os/stat p :mode) ([_] nil)))

(defn- mkdirs [dir]
  (var cur (if (string/has-prefix? "/" dir) "" "."))
  (each part (filter |(not (empty? $)) (string/split "/" dir))
    (set cur (string cur "/" part))
    (unless (= :directory (mode cur)) (os/mkdir cur))))

(defn- tpp-render [src]
  "Render `src` through tpp; return the output string, or nil on tpp failure."
  (with [in (file/open src :rb)]
    (with [out (file/temp)]
      (def code (os/execute ["tpp" (string "uname=" uname)
                             (string "hostname=" hostname)
                             (string "threads=" threads)
                             (string "home=" HOME)]
                            :p {:in in :out out}))
      (when (zero? code)
        (file/seek out :set 0)
        (string (or (:read out :all) ""))))))

(defn- write-guarded [src dest rendered]
  (def dir (string/trimr (path/dirname dest) "/"))
  (mkdirs dir)
  (def existing (try (string (slurp dest)) ([_] nil)))  # slurp yields a buffer
  (unless (and existing (= existing rendered))          # identical -> leave mtime alone
    (def tmp (string dir "/.tppd.tmp"))
    (spit tmp rendered)
    (os/chmod tmp (os/stat src :permissions))
    (os/rename tmp dest)))                               # atomic

(defn- render-one [src]
  (def rel-home (when (string/has-prefix? (string HOME-DIR "/") src)
                  (string/slice src (+ 1 (length HOME-DIR)))))
  (when rel-home
    (def name (first (string/split "/" rel-home)))
    (def target (dest-for (get manifest (keyword name))))
    (when target
      (def rel (string/slice rel-home (+ 1 (length name))))
      (def dest (string HOME "/" target "/" rel))
      (def rendered (tpp-render src))
      (if (nil? rendered)
        (eprintf "tppd: tpp failed for %s" src)
        (write-guarded src dest rendered)))))

(defn- safe [src]
  (try (render-one src) ([err] (eprintf "tppd: error on %s: %s" src err))))

(defn- walk [dir]
  (def acc @[])
  (defn rec [d]
    (each e (os/dir d)
      (def p (string d "/" e))
      (if (= :directory (mode p)) (rec p) (array/push acc p))))
  (rec dir)
  acc)

(defn- render-all []
  (each name (keys manifest)
    (def dir (string HOME-DIR "/" name))
    (when (= :directory (mode dir))
      (each f (walk dir) (safe f)))))

(defn- watch-set []
  "The change set from watchexec's env, or :full when it can't be resolved."
  (def common (or (os/getenv "WATCHEXEC_COMMON_PATH") ""))
  (def parts (mapcat |(string/split ":" (or (os/getenv $) ""))
                     ["WATCHEXEC_CREATED_PATH" "WATCHEXEC_WRITTEN_PATH"
                      "WATCHEXEC_RENAMED_PATH" "WATCHEXEC_META_CHANGED_PATH"]))
  (def raw (mapcat |(string/split "\n" $) parts))
  (def paths (filter |(not (empty? $)) raw))
  (cond
    (empty? paths) :full
    (some |(string/has-suffix? "tppd.jdn" $) paths) :full
    (let [abs (map |(if (string/has-prefix? "/" $) $ (string common "/" $)) paths)
          files (filter |(= :file (mode $)) abs)]
      (if (empty? files) :full files))))

(defn main [_prog & args]
  (if (index-of "--daemon" args)
    (let [s (watch-set)]
      (if (= s :full) (render-all) (each p s (safe p))))
    (render-all)))
