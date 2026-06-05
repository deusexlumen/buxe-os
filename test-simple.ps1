function Start-PetFight {
    $p = @{ Name = "TEST"; HP = 100; MaxHP = 100 }
    $enemy = @{ Name = "FOE"; HP = 100; MaxHP = 100 }
    Write-Host "`n  [$($p.Name)] HP: $($p.HP)/$($p.MaxHP) | [$($enemy.Name)] HP: $($enemy.HP)/$($enemy.MaxHP)" -ForegroundColor White
}
