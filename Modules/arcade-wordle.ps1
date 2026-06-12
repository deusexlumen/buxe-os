# BUXE_OS v24.4 -- WORDLE (TUI)
# Farbige Buchstaben, 500+ Woerter, Hard Mode.

try {

$script:WordleWords = @(
    "POWER","SHELL","LINUX","CODER","AGENT","PROXY","ROUTE","TABLE","QUERY","INDEX",
    "MERGE","SPLIT","PARSE","TOKEN","SCOPE","CLASS","TYPES","TRAIT","MACRO","YIELD",
    "AWAIT","ASYNC","DEFER","FINAL","CONST","VALUE","SUPER","THROW","CATCH","BREAK",
    "WHILE","UNTIL","FOR","EACH","IMPORT","EXPORT","MODULE","PACKAGE","PUBLIC","PRIVATE",
    "SEALED","ABSTRACT","VIRTUAL","OPERATOR","EVENT","DELEGATE","LAMBDA","GENERIC","DEFAULT","OPTION",
    "NULLABLE","PARTIAL","EXTERN","UNSAFE","STACK","HEAP","GLOBAL","VOLATILE","READONLY","IMMUTABLE",
    "MUTABLE","PERSIST","ATOMIC","MUTEX","THREAD","TASK","PROCESS","CONTEXT","FORMAT","CONVERT",
    "POINTER","PARAMS","DISCARD","PATTERN","MATCH","RECORD","STRUCT","UNION","VECTOR","TENSOR",
    "SCALAR","COMPLEX","STREAM","WRITER","READER","BINARY","JSON","SQL","NOSQL","MONGO",
    "REDIS","KAFKA","RABBIT","NATS","GRPC","REST","SOAP","REACT","ANGULAR","SVELTE",
    "JQUERY","EMBER","METEOR","NUXT","GATSBY","ASTRO","REMIX","IONIC","ELECTRON","TAURI",
    "FLUTTER","XAMARIN","UNITY","UNREAL","GODOT","SOURCE","RUST","SWIFT","KOTLIN","GOLANG",
    "PYTHON","PERL","RUBY","RAILS","DJANGO","FLASK","LARAVEL","SYMFONY","SPRING","QUARKUS",
    "MICRONAUT","VERT","TOMCAT","JETTY","NGINX","APACHE","IIS","CADDY","TRAEFIK","PROXY",
    "DOCKER","PODMAN","KUBERNETES","HELM","ISTIO","VAULT","CONSUL","NOMAD","TERRAFORM","ANSIBLE",
    "PUPPET","CHEF","SALT","VAGRANT","PACKER","JENKINS","GITLAB","GITHUB","CIRCLE","TRAVIS",
    "AZURE","AWS","GCP","ORACLE","DIGITAL","LINODE","HEROKU","NETLIFY","VERCEL","CLOUDFLARE",
    "SERVER","STORAGE","BLOCK","OBJECT","BLOB","CACHE","QUEUE","STREAM","PIPELINE","WEBHOOK",
    "CALLBACK","PUBLISH","SUBSCRIBE","ROUTING","SWITCH","GATEWAY","FIREWALL","LOAD","BALANCER",
    "TUNNEL","ENCRYPT","DECRYPT","HASH","CIPHER","AES","RSA","ECC","SHA","TLS",
    "HTTPS","SSH","SCP","RSYNC","CLONE","BRANCH","MERGE","COMMIT","STASH","CHERRY",
    "JIRA","SLACK","TEAMS","ZOOM","DISCORD","MATRIX","NOTION","TODOIST","CALENDAR","INBOX",
    "DOMAIN","HOSTNAME","DNSSEC","RECORD","DIG","PING","TRACE","NMAP","ZMAP","SCAN",
    "RAID","NAS","SAN","NVME","SSD","HDD","VOLUME","MOUNT","SHARE","BACKUP",
    "CPU","GPU","TPU","NPU","DPU","FPGA","ASIC","SOC","MCU","MPU",
    "HBM","GDDR","DDR","SRAM","DRAM","FLASH","CACHE","REGISTER","PIPELINE","BRANCH",
    "KERNEL","USER","DRIVER","MODULE","SYSCALL","INTERRUPT","EXCEPTION","PAGETABLE","SEGMENT","OFFSET",
    "HYPERVISOR","XEN","KVM","QEMU","VMWARE","VBOX","WINE","PROTON","MESA","GALLIUM",
    "COMPILER","DEBUGGER","ASSEMBLER","DISASSEMBLER","REFACTOR","VARIABLE","FUNCTION","METHOD","PROPERTY","CONSTRUCTOR",
    "INHERITANCE","POLYMORPHISM","ENCAPSULATION","ABSTRACTION","INTERFACE","INJECTION","SINGLETON","FACTORY","OBSERVER","STRATEGY",
    "ADAPTER","FACADE","DECORATOR","COMPOSITE","COMMAND","ITERATOR","MEDIATOR","MEMENTO","STATE","TEMPLATE",
    "VISITOR","BRIDGE","FLYWEIGHT","BUILDER","PROTOTYPE","HANDLER","MIDDLEWARE","ENDPOINT","REQUEST","RESPONSE",
    "PAYLOAD","HEADER","COOKIE","SESSION","AUTH","OAUTH","JWT","TOKEN","SAML","LDAP",
    "CERT","OCSP","CRL","TRUSTSTORE","KEYSTORE","FIREWALL","IPTABLES","SURICATA","SNORT","WAF",
    "MITIGATE","CDN","EDGE","CLUSTER","NODE","POD","SERVICE","DEPLOY","REPLICA","DAEMON",
    "STATEFUL","CRONJOB","INGRESS","EGRESS","NETWORK","POLICY","SECRET","CONFIGMAP","QUOTA","LIMIT",
    "METRICS","LOGGING","TRACING","PROFILE","BENCH","LATENCY","THROUGHPUT","SYNC","DEADLOCK","RACE",
    "LEAK","OVERFLOW","UNDERFLOW","DIVIDE","MODULO","POWER","SQRT","ROUND","FLOOR","CEIL",
    "LOGARITHM","EXPONENT","SINE","COSINE","TANGENT","RADIAN","DEGREE","VECTOR","MATRIX","ARRAY",
    "LIST","QUEUE","STACK","TREE","GRAPH","HASHMAP","SET","MAP","DICT","TUPLE",
    "STRING","CHAR","BYTE","INT","FLOAT","DOUBLE","DECIMAL","BOOLEAN","NULL","VOID",
    "UNIT","NEVER","ANY","UNKNOWN","DYNAMIC","STATIC","CONST","LET","VAR","DEF",
    "CLASS","ENUM","TYPE","ALIAS","IMPORT","USING","FROM","INTO","WHERE","SELECT",
    "INSERT","UPDATE","DELETE","CREATE","ALTER","DROP","GRANT","REVOKE","BEGIN","ROLLBACK",
    "COMMIT","SAVEPOINT","TRANSACTION","ISOLATION","CONSISTENCY","DURABILITY","AVAILABILITY","PARTITION","REPLICATE","SHARD",
    "SPLIT","MERGE","JOIN","GROUP","ORDER","HAVING","UNION","EXCEPT","INTERSECT","OFFSET",
    "FETCH","CURSOR","TRIGGER","PROCEDURE","FUNCTION","VIEW","INDEX","CONSTRAINT","PRIMARY","FOREIGN",
    "UNIQUE","CHECK","DEFAULT","CASCADE","RESTRICT","COLLATE","ENCODING","COLLATION","SEQUENCE","SCHEMA",
    "CATALOG","DATABASE","INSTANCE","SERVER","CLIENT","SOCKET","PACKET","FRAME","SEGMENT","DATAGRAM",
    "PROTOCOL","HANDSHAKE","ACK","SYN","FIN","RST","PUSH","URGENT","WINDOW","CONGESTION",
    "SLOWSTART","RECOVERY","RETRANSMIT","TIMEOUT","LATENCY","JITTER","BANDWIDTH","THROUGHPUT","CAPACITY","UTILIZATION",
    "OVERHEAD","FOOTPRINT","MEMORY","ALLOCATE","FREE","COLLECT","GC","HEAP","STACK","POOL",
    "BUFFER","STREAM","CHANNEL","PIPE","FIFO","SIGNAL","SEMAPHORE","MUTEX","LOCK","SPINLOCK",
    "RWLOCK","BARRIER","LATCH","CONDITION","MONITOR","CRITICAL","SECTION","ATOMIC","IDEMPOTENT","DETERMINISTIC",
    "PREDICTABLE","RELIABLE","RESILIENT","ROBUST","FAULT","TOLERANT","GRACEFUL","DEGRADE","FAILOVER","SWITCHOVER",
    "RECOVERY","RESTORE","REBUILD","REPAIR","HEALTH","CHECK","PROBE","HEARTBEAT","PING","PONG",
    "WATCHDOG","TIMEOUT","EXPIRE","REFRESH","RENEW","REVOKE","INVALIDATE","EVICT","FLUSH","CLEAR",
    "RESET","REBOOT","RESTART","RELOAD","REFRESH","UPDATE","UPGRADE","PATCH","HOTFIX","RELEASE",
    "VERSION","BUILD","DEPLOY","STAGE","PROD","DEV","TEST","QA","UAT","DEMO",
    "SANDBOX","CANARY","BLUE","GREEN","A/B","FEATURE","TOGGLE","FLAG","EXPERIMENT","ROLLOUT",
    "MIGRATE","IMPORT","EXPORT","CLONE","FORK","SYNC","REBASE","RESET","CHECKOUT","BLAME",
    "BISECT","TAG","ANNOTATE","SIGN","VERIFY","TRUST","GPG","PGP","SSH","TLS",
    "MTLS","OCSP","STAPLE","PINNING","HSTS","CSP","CORS","CSRF","XSS","SQLI",
    "LFI","RFI","XXE","SSRF","RCE","LPE","BOF","ROP","SHELLCODE","EXPLOIT",
    "PAYLOAD","SHELL","REVERSE","BIND","LISTENER","ENCODER","DECODER","OBFUSCATE","PACK","CRYPT",
    "STEGO","FORENSIC","INCIDENT","RESPONSE","THREAT","HUNT","INTEL","OSINT","SIGINT","HUMINT",
    "IMINT","MASINT","GEOINT","CYBER","WARFARE","KILLCHAIN","RECON","WEAPONIZE","DELIVER","EXPLOIT",
    "INSTALL","COMMAND","CONTROL","ACTION","OBJECTIVE","EXFILTRATE","IMPACT","BREACH","LEAK","DUMP",
    "PASTEBIN","DARKWEB","TOR","I2P","FREENET","ZERONET","IPFS","DAT","SSB","MATRIX",
    "XMPP","IRC","MUMBLE","TEAMSPEAK","VENTRILO","DISCORD","SLACK","TEAMS","ZOOM","MEET",
    "WEBEX","GOTO","SKYPE","HANGOUTS","DUO","ALLO","WAVE","BUZZ","ORKUT","FRIENDSTER",
    "MYSPACE","XING","LINKEDIN","FACEBOOK","TWITTER","INSTAGRAM","SNAPCHAT","WHATSAPP","TELEGRAM","SIGNAL",
    "THREEMA","WICKR","WIRE","KEYBASE","STATUS","BRIAR","JAMI","TOX","RING","DELTA",
    "SESSION","SIMPLEX","CWTCH","RICOCHET","ONION","HIDDEN","SERVICE","MIXNET","VPN","PROXY",
    "SOCKS","HTTP","FTP","SMTP","IMAP","POP3","NNTP","IRC","DNS","DHCP",
    "BOOTP","TFTP","SNMP","LDAP","KERBEROS","SMB","NFS","AFS","CIFS","ISCSI",
    "FIBRE","INFINIBAND","RDMA","MPI","OPENMP","CUDA","OPENCL","VULKAN","METAL","DIRECTX",
    "OPENGL","WEBGL","WEBGPU","CANVAS","SVG","WEBRTC","WEBSOCKET","SSE","LONGPOLLING","COMET",
    "BOSH","XMPP","MQTT","AMQP","STOMP","ZERO","NANOMSG","REDIS","MEMCACHED","VARNISH",
    "SQUID","TRAEFIK","ENVOY","CONSUL","ETCD","ZOOKEEPER","BOOKKEEPER","PULSAR","ROCKET","ACTIVE",
    "HORNET","ARTEMIS","QPID","RABBIT","CELERY","HUEY","RQ","BULL","BEE","AGENDA",
    "NODE","CRON","BULLMQ","GRAPHILE","PGBOSS","Faktory","VerneMQ","HiveMQ","EMQ","Mosquitto",
    "Mosca","Aedes","KAFKA","PULSAR","KINESIS","EVENTHUB","PUBSUB","SNS","SQS","EVENTBRIDGE",
    "LAMBDA","FUNCTION","WORKER","CRON","SCHEDULER","ORCHESTRATOR","DAG","AIRFLOW","PREFECT","DAGSTER",
    "LUIGI","PINEBOX","AZKABAN","OOZIE","NIFFI","STREAMSETS","DATAFLOW","DATAPROC","EMR","DMS",
    "GLUE","LAKE","FORMATION","ATHENA","QUICKSIGHT","REDASH","SUPERSET","METABASE","LOOKER","TABLEAU",
    "POWERBI","QLIK","DOMO","SISENSE","THOUGHT","SPOT","TIBCO","MICROSTRATEGY","SAS","SPSS",
    "STATA","MATLAB","MATHEMATICA","MAPLE","MUPAD","SAGE","JULIA","RUST","GO","ZIG",
    "NIM","CRYSTAL","DART","ELIXIR","ERLANG","HASKELL","OCAML","FSTAR","AGDA","IDRIS",
    "COQ","ISABELLE","LEAN","TWELF","ELF","OTT","PLT","RACKET","SCHEME","LISP",
    "CLOJURE","ARC","DYLAN","FACTOR","FORTH","APL","J","K","Q","BQN",
    "UIUA","WREN","GRAIN","GLEAN","PONY","CAPN","BROOK","CHPEL","REGENT","LEGION",
    "PAaja","TACO","TVM","MLIR","LLVM","CLANG","GCC","MSVC","ICC","TCC",
    "CHIBI","GUILE","CHICKEN","GAUCHE","BIGLOO","LIPS","NEWLISP","PICOLISP","MAXIMA","REDUCE",
    "AXIOM","FRI","GAP","MACAULAY","SINGULAR","PARI","MIRACL","CRYPTOPP","OPENSSL","LIBRESSL",
    "BORING","WOLFSSL","GNUTLS","NSS","SCHANNEL","SECURE","TRANSPORT","NETWORK","FOUNDATION","LIBCURL",
    "LIBSSH","LIBGIT","ZLIB","BZIP","XZ","LZ4","ZSTD","BROTLI","SNAPPY","LZO",
    "QUICKLZ","LIZARD","BLosc","CBlosc","BITSHUFFLE","SHUFFLE","DELTA","RLE","HUFFMAN","ARITHMETIC",
    "ANS","FSE","TANS","RANS","DUDA","JAREK","YANN","FABIAN","ROSS","MIKE",
    "MARK","RICH","BRIAN","GUIDO","BRENDAN","RYAN","YUKI","MATZ","LARRY","WALL",
    "DAMIAN","CONWAY","AUDREY","TANG","INGY","DOT","MIYAGAWA","RANDLE","SCHWARTZ","BRIAN",
    "FOY","CHROMATIC","TIM","TOADY","JONATHAN","WORTHINGTON","STEFAN","SEIFERT","ALEIX","POL",
    "FERRAN","JORDI","BINO","CARLOS","DANIEL","JAKOB","NICK","LOGAN","PAUL","GRAHAM",
    "PETER","NORVIG","DONALD","KNUTH","TONY","HOARE","EDSGER","DIJKSTRA","ALAN","TURING",
    "JOHN","VON","NEUMANN","CLaude","SHANNON","GRACE","HOPPER","ADA","LOVELACE","CHARLES",
    "BABBAGE","GEORGE","BOOLE","AUGUSTUS","DEMORGAN","GOTTLOB","FREGE","BERTRAND","RUSSELL","ALFRED",
    "WHITEHEAD","KURT","GODEL","ALONZO","CHURCH","STEPHEN","KLEENE","HASKELL","CURRY","JOHN",
    "MCCARTHY","MARVIN","MINSKY","SEYMOUR","PAPERT","ED","FEIGENBAUM","JOSHUA","LENAT","DOUG",
    "LENAT","PATTIE","MAES","RODNEY","BROOKS","HANS","MORAVEC","RAY","KURZWEIL","ELON",
    "MUSK","JEFF","BEZOS","BILL","GATES","STEVE","JOBS","WOZ","MARK","ZUCKERBERG",
    "LARRY","PAGE","SERGEY","BRIN","SUNDAR","PICHAI","SATYA","NADELLA","TIM","COOK",
    "JENSEN","HUANG","LISA","SU","PAT","GELSINGER","RENE","HAAS","SIMON","SEGARS",
    "ARM","HOLDING","SOFTBANK","VISION","FUND","ALPHABET","META","APPLE","MICROSOFT","AMAZON",
    "TESLA","SPACEX","NEURALINK","BORING","OPENAI","ANTHROPIC","COHERE","AI21","HUGGING","FACE",
    "STABILITY","MIDJOURNEY","DALLE","GPT","CLAD","LLAMA","MISTRAL","FALCON","BERT","T5",
    "BART","PEGASUS","TURING","NGL","ALBERT","ROBERTA","DEBERTA","ELECTRA","XLNET","REFORMER",
    "LONGFORMER","BIGBIRD","PERFORMER","LINFORMER","NYSTROM","RECEPTIVE","SWIN","VIT","DETR","MASK",
    "RCNN","YOLO","SSD","EFFICIENT","DET","SEGMENT","SAM","DINO","CLIP","ALIGN",
    "BLIP","FLAVA","DATA","TWOCLEAN","BEIT","MAE","SIM","MIM","CONTRASTIVE","SUPERVISED",
    "SEMI","SELF","FEW","SHOT","ZERO","TRANSFER","MULTI","TASK","META","LEARNING",
    "FEDERATED","DISTRIBUTED","PARALLEL","SEQUENTIAL","ONLINE","OFFLINE","BATCH","MINI","STOCHASTIC","GRADIENT",
    "DESCENT","ASCENT","NEWTON","QUASI","BFGS","L-BFGS","ADAM","RMSPROP","ADAGRAD","ADADELTA",
    "ADAMW","LAMB","LAION","NOVO","MADGRAD","YOGI","LOOKAHEAD","SWA","EMA","CHECKPOINT",
    "AVERAGING","ENSEMBLE","VOTING","STACKING","BAGGING","BOOSTING","ADABOOST","GRADIENT","XGBOOST","LIGHT",
    "CATBOOST","HIST","RANDOM","FOREST","EXTRATREES","DECISION","TREE","CART","ID3","C45",
    "CHAID","MARS","RULEFIT","SLIPPER","RIPPER","CN2","FOIL","AQ","APRIORI","ECLAT",
    "FPGROWTH","SPADE","PREFIX","GSP","CPS","KMEANS","DBSCAN","OPTICS","HDBSCAN","BIRCH",
    "MEAN","SHIFT","AFFINITY","SPECTRAL","AGGLOMERATIVE","DIVISIVE","WARD","LINKAGE","DENDROGRAM","SILHOUETTE",
    "CALINSKI","DAVIES","BOULDIN","GAP","STATISTIC","ELBOW","SCREE","PCA","SVD","LDA",
    "NMF","ICA","FA","TSNE","UMAP","MDS","ISOMAP","LLE","LAPLACIAN","EIGEN",
    "HESSIAN","LTSA","DIFFUSION","SPECTRAL","EMBEDDING","AUTOENCODER","VAE","GAN","WASSERSTEIN","CGAN",
    "DCGAN","PROGAN","STYLE","BIGGAN","SAGAN","SELF","ATTENTION","TRANSFORMER","BERT","GPT",
    "T5","BART","PEGASUS","REFORMER","LONGFORMER","BIGBIRD","PERFORMER","LINFORMER","NYSTROM","SWIN",
    "VIT","DETR","MASK","RCNN","YOLO","SSD","EFFICIENT","DET","SEGMENT","SAM"
) | Where-Object { $_ -match '^[A-Z]{5}$' }

function wordle {
    # Mode selection
    try { Clear-Host } catch {}
    Show-Frame "WORDLE" -Double | Out-Null
    Write-Host ""
    Write-Host "  [1] Normal Mode" -ForegroundColor White
    Write-Host "  [2] Hard Mode" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  [Q] Quit" -ForegroundColor DarkGray
    Write-Host ""
    $mode = Read-GameChoice "" "^[12Q]$"
    if ($mode -eq 'Q') { return }
    $hardMode = ($mode -eq '2')
    
    $target = ($script:WordleWords | Get-Random).ToUpper()
    $attempts = 0; $maxAttempts = 6
    $history = @()
    $mustUse = @()
    
    while ($attempts -lt $maxAttempts) {
        try { Clear-Host } catch {}
        Show-Frame "WORDLE" -Double | Out-Null
        Write-Host ""
        Write-Host "  Errate das Wort in $maxAttempts Versuchen!" -ForegroundColor White
        Write-Host "  Laenge: $($target.Length) Buchstaben" -ForegroundColor DarkGray
        if ($hardMode) { Write-Host "  HARD MODE - Aufgedeckte Buchstaben muessen verwendet werden!" -ForegroundColor Red }
        Write-Host ""
        
        foreach ($entry in $history) {
            Write-Host "  " -NoNewline
            for ($i = 0; $i -lt $entry.Guess.Length; $i++) {
                Write-Host $entry.Guess[$i] -NoNewline -ForegroundColor $entry.Colors[$i]
            }
            Write-Host ""
        }
        
        Write-Host ""
        try { [Console]::CursorVisible = $true } catch {}
        $guess = (Read-GameInput "  Versuch $($attempts+1)/${maxAttempts}:").ToUpper()
        try { [Console]::CursorVisible = $false } catch {}
        
        if ($guess -eq 'Q') { return }
        if ($guess.Length -ne $target.Length -or $guess -notmatch '^[A-Z]{5}$') {
            Write-Host "  Ungueltig! ($($target.Length) Buchstaben, nur A-Z)" -ForegroundColor Red
            Start-Sleep -Milliseconds 800
            continue
        }
        if ($script:WordleWords -notcontains $guess) {
            Write-Host "  Nicht in der Wortliste!" -ForegroundColor Red
            Start-Sleep -Milliseconds 800
            continue
        }
        
        # Hard mode validation
        if ($hardMode -and $mustUse.Count -gt 0) {
            $validGuess = $true
            $guessCounts = @{}
            foreach ($c in $guess.ToCharArray()) { $guessCounts[$c] = ($guessCounts[$c] + 1) }
            foreach ($req in $mustUse) {
                if ($req.Position -ne $null) {
                    if ($guess[$req.Position] -ne $req.Letter) { $validGuess = $false; break }
                } else {
                    $yellowCount = ($mustUse | Where-Object { $_.Letter -eq $req.Letter -and $_.Position -eq $null }).Count
                    if (($guessCounts[$req.Letter] -or 0) -lt $yellowCount) { $validGuess = $false; break }
                }
            }
            if (-not $validGuess) {
                Write-Host "  Hard Mode: Alle aufgedeckten Buchstaben muessen verwendet werden!" -ForegroundColor Red
                Start-Sleep -Milliseconds 1200
                continue
            }
        }
        
        $attempts++
        $colors = @()
        $newMustUse = @()
        $targetCounts = @{}
        foreach ($c in $target.ToCharArray()) {
            $targetCounts[$c] = ($targetCounts[$c] + 1)
        }
        
        # First pass: greens
        for ($i = 0; $i -lt $target.Length; $i++) {
            if ($guess[$i] -eq $target[$i]) {
                $colors += "Green"
                $targetCounts[$guess[$i]]--
                $newMustUse += @{ Letter = $guess[$i]; Position = $i }
            } else {
                $colors += $null
            }
        }
        
        # Second pass: yellows and grays
        for ($i = 0; $i -lt $target.Length; $i++) {
            if ($colors[$i] -eq $null) {
                if ($target.Contains($guess[$i]) -and $targetCounts[$guess[$i]] -gt 0) {
                    $colors[$i] = "Yellow"
                    $targetCounts[$guess[$i]]--
                    $existing = $newMustUse | Where-Object { $_.Letter -eq $guess[$i] -and $_.Position -eq $null }
                    if (-not $existing) {
                        $newMustUse += @{ Letter = $guess[$i]; Position = $null }
                    }
                } else {
                    $colors[$i] = "DarkGray"
                }
            }
        }
        
        $history += @{ Guess = $guess; Colors = $colors }
        $mustUse = $newMustUse
        
        if ($guess -eq $target) {
            try { Clear-Host } catch {}
            Show-Frame "WORDLE" -Double | Out-Null
            Write-Host ""
            Write-Host "  RICHTIG!" -ForegroundColor Green
            Write-Host "  '$target' in $attempts Versuchen!" -ForegroundColor Green
            Write-Host ""
            foreach ($entry in $history) {
                Write-Host "  " -NoNewline
                for ($i = 0; $i -lt $entry.Guess.Length; $i++) {
                    Write-Host $entry.Guess[$i] -NoNewline -ForegroundColor $entry.Colors[$i]
                }
                Write-Host ""
            }
            
            Load-State
            $stats = Get-ArcadeStats "Wordle"
            if (-not $stats.Played) { $stats.Played = 0 }
            if (-not $stats.Streak) { $stats.Streak = 0 }
            if (-not $stats.BestStreak) { $stats.BestStreak = 0 }
            if (-not $stats.HardModeWins) { $stats.HardModeWins = 0 }
            $stats.Played++
            $stats.Streak++
            if ($stats.Streak -gt $stats.BestStreak) { $stats.BestStreak = $stats.Streak }
            if ($hardMode) { $stats.HardModeWins++ }
            Set-ArcadeStats "Wordle" $stats
            Save-State
            if ($attempts -le 3) { Unlock-Achievement "Wordle Master" }
            Wait-Enter
            return
        }
    }
    
    # Game over
    try { Clear-Host } catch {}
    Show-Frame "WORDLE" -Double | Out-Null
    Write-Host ""
    Write-Host "  Game Over!" -ForegroundColor Red
    Write-Host "  Das Wort war: $target" -ForegroundColor Yellow
    Write-Host ""
    foreach ($entry in $history) {
        Write-Host "  " -NoNewline
        for ($i = 0; $i -lt $entry.Guess.Length; $i++) {
            Write-Host $entry.Guess[$i] -NoNewline -ForegroundColor $entry.Colors[$i]
        }
        Write-Host ""
    }
    
    Load-State
    $stats = Get-ArcadeStats "Wordle"
    if (-not $stats.Played) { $stats.Played = 0 }
    if (-not $stats.Streak) { $stats.Streak = 0 }
    $stats.Played++
    $stats.Streak = 0
    Set-ArcadeStats "Wordle" $stats
    Save-State
    Wait-Enter
}

} catch {
    Write-Host "[arcade-wordle] CRITICAL ERROR: $($_)" -ForegroundColor Red
}
