# BUXE_OS v24.4 -- MONKEYTYPE (TUI)
# Wort- und Satz-Modus, 200+ Woerter, Genauigkeitstracking.

try {

$script:MonkeyTypeWords = @(
    "algorithm","bandwidth","cybernetic","debugging","encryption","firewall","gigabyte","hardware","interface","javascript",
    "kernel","latency","malware","network","operating","protocol","quantum","router","system","terminal",
    "unix","virtual","wireless","xenon","yield","zipfile","powershell","repository","framework","container",
    "kubernetes","blockchain","cryptography","datacenter","ethernet","filesystem","gateway","hyperlink","iteration","junction",
    "keystore","localhost","middleware","namespace","overlay","pipeline","queryset","runtime","sandbox","timestamp",
    "upstream","viewport","webhook","xmlhttp","yamlfile","zeroday","compiler","debugger","interpreter","assembler",
    "disassembler","decompiler","refactor","variable","function","method","property","constructor","destructor","inheritance",
    "polymorphism","encapsulation","abstraction","implementation","dependency","injection","singleton","factory","observer","strategy",
    "adapter","facade","proxy","decorator","composite","command","iterator","mediator","memento","state",
    "template","visitor","bridge","flyweight","builder","prototype","handler","middleware","endpoint","request",
    "response","payload","header","cookie","session","authentication","authorization","permission","credential","password",
    "hashing","salting","token","oauth","openid","saml","ldap","kerberos","certificate","keystore",
    "truststore","revocation","iptables","nftables","ufw","fail2ban","suricata","zeek","snort","ids",
    "ips","waf","ddos","mitigation","loadbalancer","reverseproxy","cdn","edgecomputing","cluster","node",
    "pod","service","deployment","replicaset","daemonset","statefulset","cronjob","ingress","egress","networkpolicy",
    "serviceaccount","role","rolebinding","clusterrole","persistentvolume","configmap","secret","namespace","resourcequota","limitrange",
    "priorityclass","runtimeclass","horizontal","vertical","autoscaler","metrics","logging","tracing","profiling","benchmark",
    "latency","throughput","concurrency","parallelism","synchronization","deadlock","livelock","starvation","racecondition","memoryleak",
    "bufferoverflow","stackoverflow","underflow","exception","error","warning","fatal","critical","verbose","debug",
    "trace","audit","rollback","checkout","branch","merge","rebase","cherrypick","bisect","blame",
    "stash","tag","release","version","changelog","readme","license","contributing","security","issue",
    "pullrequest","review","comment","approval","build","test","deploy","monitor","alert","incident",
    "postmortem","runbook","playbook","automation","orchestration","provisioning","configuration","management","observability","reliability",
    "availability","durability","scalability","elasticity","resilience","redundancy","backup","recovery","disaster","continuity",
    "fallback","circuitbreaker","bulkhead","retry","timeout","throttling","ratelimiting","quotas","sharding","partitioning",
    "replication","consistency","tolerance","isolation","atomicity","eventual","strong","weak","session","monotonic",
    "causal","serializable","readcommitted","snapshot","optimistic","pessimistic","locking","latching","semaphore","condition",
    "barrier","countdown","exchanger","phaser","forkjoin","completable","future","promise","deferred","observable",
    "subscriber","publisher","processor","transform","filter","map","reduce","collect","group","window",
    "buffer","sample","debounce","throttle","distinct","sorted","merged","zipped","combined","concatenated",
    "flattened","scanned","folded","accumulated","generated","iterated"
)

$script:MonkeyTypeSentences = @(
    "The quick brown fox jumps over the lazy dog.",
    "sudo apt update && sudo apt upgrade -y",
    "git commit -m 'fixed the thing that was broken'",
    "docker run -it --rm ubuntu:latest bash",
    "kubectl get pods --all-namespaces -o wide",
    "SELECT * FROM users WHERE active = 1 LIMIT 100;",
    "function Invoke-Magic { param([string]$Spell); Write-Host 'Abracadabra!' }",
    "The compiler threw an exception at line forty two.",
    "Terraform apply completed with zero resources changed.",
    "npm install left-pad && rm -rf node_modules",
    "while true; do echo 'hello world'; sleep 1; done",
    "curl -s https://api.github.com/users/octocat | jq .",
    "python -c 'import this; print(42)'",
    "chmod 755 deploy.sh && ./deploy.sh --env production",
    "kubernetes networking is powered by CNI plugins.",
    "The heap overflow corrupted the stack canary value.",
    "CI pipeline failed at stage three with exit code one.",
    "Refactor the monolith into microservices they said.",
    "Edge computing brings the cloud closer to the user.",
    "Blockchain is just a linked list with extra marketing.",
    "Machine learning models are only as good as their data.",
    "The debugger stepped into a recursive rabbit hole.",
    "Serverless does not mean there are no servers.",
    "Zero trust means verify every request every time.",
    "Immutable infrastructure is the key to reliable deployments.",
    "Infrastructure as code is just programming with YAML.",
    "The API returned HTTP four hundred and twenty nine.",
    "Latency is the new throughput in distributed systems.",
    "Event driven architecture scales better than synchronous RPC.",
    "Garbage collection paused the world for two milliseconds.",
    "The quantum computer factored fifteen in record time.",
    "Neural networks are inspired by biological neurons.",
    "Cache invalidation is one of the hardest problems.",
    "Off by one errors are the bane of every programmer.",
    "To understand recursion you must first understand recursion.",
    "There are ten types of people those who understand binary.",
    "A SQL query walks into a bar and joins two tables.",
    "It works on my machine is not a deployment strategy.",
    "Technical debt is the interest you pay on bad decisions.",
    "The cloud is just someone elses computer with better uptime."
)

function monkeytype {
    # Mode selection
    try { Clear-Host } catch {}
    Show-Frame "MONKEYTYPE" -Double | Out-Null
    Write-Host ""
    Write-Host "  [1] Word Mode" -ForegroundColor White
    Write-Host "  [2] Sentence Mode" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [Q] Quit" -ForegroundColor DarkGray
    Write-Host ""
    $mode = Read-GameChoice "" "^[12Q]$"
    if ($mode -eq 'Q') { return }
    $sentenceMode = ($mode -eq '2')
    
    if ($sentenceMode) {
        $target = ($script:MonkeyTypeSentences | Get-Random)
    } else {
        $wordCount = 10
        $target = ($script:MonkeyTypeWords | Get-Random -Count $wordCount) -join ' '
    }
    
    # Pre-game screen
    try { Clear-Host } catch {}
    Show-Frame "MONKEYTYPE" -Double | Out-Null
    Write-Host ""
    Write-Host "  Tippe diesen Text so schnell wie moeglich:" -ForegroundColor White
    Write-Host ""
    Write-Host "  $target" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  [ENTER] Start" -ForegroundColor Green
    Write-Host "  [Q] Quit" -ForegroundColor DarkGray
    Write-Host ""
    $act = Read-GameChoice "" "^[Q\r\n]$"
    if ($act -eq 'Q') { return }
    
    # Input phase
    try { Clear-Host } catch {}
    Show-Frame "MONKEYTYPE" -Double | Out-Null
    Write-Host ""
    Write-Host "  $target" -ForegroundColor Yellow
    Write-Host ""
    try { [Console]::CursorVisible = $true } catch {}
    $start = Get-Date
    $input = Read-GameInput "  >"
    $elapsed = (Get-Date) - $start
    try { [Console]::CursorVisible = $false } catch {}
    $seconds = $elapsed.TotalSeconds
    
    # Result
    $trimmedInput = $input.Trim()
    $targetChars = $target.ToCharArray()
    $inputChars = $trimmedInput.ToCharArray()
    $correct = 0
    $total = [math]::Max($targetChars.Count, $inputChars.Count)
    for ($i = 0; $i -lt $total; $i++) {
        $tc = if ($i -lt $targetChars.Count) { $targetChars[$i] } else { $null }
        $ic = if ($i -lt $inputChars.Count) { $inputChars[$i] } else { $null }
        if ($tc -eq $ic) { $correct++ }
    }
    $accuracy = if ($total -gt 0) { [math]::Round(($correct / $total) * 100) } else { 0 }
    $typedWords = if ($trimmedInput.Length -gt 0) { [math]::Max(1, $trimmedInput.Split(' ').Count) } else { 0 }
    $wpm = if ($seconds -gt 0) { [math]::Round((($typedWords / $seconds) * 60)) } else { 0 }
    
    try { Clear-Host } catch {}
    Show-Frame "MONKEYTYPE" -Double | Out-Null
    Write-Host ""
    
    if ($trimmedInput -eq $target) {
        Write-Host "  PERFECT!" -ForegroundColor Green
    } else {
        Write-Host "  Fertig!" -ForegroundColor Cyan
    }
    Write-Host "  Zeit: $([math]::Round($seconds,1))s | WPM: $wpm | Genauigkeit: $accuracy%" -ForegroundColor Cyan
    Write-Host ""
    if ($trimmedInput -ne $target) {
        Write-Host "  Erwartet: $target" -ForegroundColor Yellow
        Write-Host "  Deine:    $trimmedInput" -ForegroundColor DarkGray
    }
    
    Load-State
    $stats = Get-ArcadeStats "MonkeyType"
    if (-not $stats.Races) { $stats.Races = 0 }
    if (-not $stats.BestWPM) { $stats.BestWPM = 0 }
    if (-not $stats.BestAccuracy) { $stats.BestAccuracy = 0 }
    $stats.Races = $stats.Races + 1
    $isRecord = $false
    if ($wpm -gt $stats.BestWPM) {
        $stats.BestWPM = $wpm
        $isRecord = $true
    }
    if ($accuracy -gt $stats.BestAccuracy) {
        $stats.BestAccuracy = $accuracy
    }
    Set-ArcadeStats "MonkeyType" $stats
    Save-State
    
    if ($isRecord) { Write-Host "  NEUER REKORD WPM!" -ForegroundColor Yellow }
    if ($wpm -ge 60) {
        Unlock-Achievement "Speed Demon"
        Write-Host "  Achievement: Speed Demon!" -ForegroundColor Magenta
    }
    
    Wait-Enter
}

} catch {
    Write-Host "[arcade-monkeytype] CRITICAL ERROR: $($_)" -ForegroundColor Red
}
