$ErrorActionPreference = 'Stop'

Clear-Host
$directory = '' ##INFONRME O DIRETÓRIO QUE DESEJA COMPARTILHAR LOCALMENTE
$defaultPort = 8000

Write-Host ('=' * 68) -ForegroundColor DarkCyan
Write-Host '                 SERVIDOR HTTP DE ARQUIVOS' -ForegroundColor Cyan
Write-Host '               Compartilhamento na rede local' -ForegroundColor Gray
Write-Host ('=' * 68) -ForegroundColor DarkCyan
Write-Host ''
Write-Host '[1/4] Verificando os requisitos...' -ForegroundColor Cyan

$resolvedDirectory = Resolve-Path -LiteralPath $directory -ErrorAction SilentlyContinue
if (-not $resolvedDirectory -or -not (Test-Path -LiteralPath $resolvedDirectory.Path -PathType Container)) {
    Write-Error "A pasta a compartilhar não foi encontrada: $directory"
    exit 1
}
Write-Host "  Pasta: $($resolvedDirectory.Path)" -ForegroundColor Green

$python = Get-Command -Name 'python' -CommandType Application -ErrorAction SilentlyContinue |
    Select-Object -First 1
if (-not $python) {
    Write-Error 'Python não foi encontrado no PATH. Instale o Python ou ajuste a variável PATH.'
    exit 1
}

Write-Host ''
Write-Host '[2/4] Configuração da porta' -ForegroundColor Cyan
do {
    $portInput = Read-Host "  Porta (ENTER usa $defaultPort)"
    if ([string]::IsNullOrWhiteSpace($portInput)) {
        $port = $defaultPort
        break
    }

    $portNumber = 0
    $validPort = [int]::TryParse($portInput, [ref]$portNumber) -and
        $portNumber -ge 1 -and $portNumber -le 65535
    if (-not $validPort) {
        Write-Host 'Porta inválida. Digite um número entre 1 e 65535.' -ForegroundColor Yellow
    }
} until ($validPort)

if ($validPort) {
    $port = $portNumber
}
Write-Host "  Porta selecionada: $port" -ForegroundColor Green

Write-Host ''
Write-Host '[3/4] Seleção da interface de rede' -ForegroundColor Cyan
$activeAdapters = @(Get-NetAdapter -ErrorAction Stop | Where-Object { $_.Status -eq 'Up' })
$ipCandidates = @(
    foreach ($adapter in $activeAdapters) {
        Get-NetIPAddress -InterfaceIndex $adapter.InterfaceIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue |
            Where-Object {
                $_.IPAddress -ne '127.0.0.1' -and
                $_.IPAddress -notlike '169.254.*' -and
                $_.AddressState -eq 'Preferred'
            } |
            ForEach-Object {
                [pscustomobject]@{
                    IPAddress = $_.IPAddress
                    Adapter   = $adapter.Name
                }
            }
    }
)

if ($ipCandidates.Count -eq 0) {
    Write-Error 'Não foi encontrado um endereço IPv4 válido em um adaptador ativo.'
    exit 1
}

if ($ipCandidates.Count -eq 1) {
    $selectedIP = $ipCandidates[0].IPAddress
    Write-Host "  Interface: $($ipCandidates[0].Adapter) ($selectedIP)" -ForegroundColor Green
}
else {
    Write-Host ''
    Write-Host ('  {0,-5} {1,-18} {2}' -f 'Nº', 'ENDEREÇO IPv4', 'ADAPTADOR') -ForegroundColor White
    for ($index = 0; $index -lt $ipCandidates.Count; $index++) {
        Write-Host ('  {0,-5} {1,-18} {2}' -f `
            "[$($index + 1)]", $ipCandidates[$index].IPAddress, $ipCandidates[$index].Adapter) -ForegroundColor Gray
    }

    do {
        $selection = Read-Host '  Escolha o número do adaptador'
        $selectionNumber = 0
        $validSelection = [int]::TryParse($selection, [ref]$selectionNumber) -and
            $selectionNumber -ge 1 -and $selectionNumber -le $ipCandidates.Count
        if (-not $validSelection) {
            Write-Host 'Seleção inválida.' -ForegroundColor Yellow
        }
    } until ($validSelection)

    $selectedIP = $ipCandidates[$selectionNumber - 1].IPAddress
    Write-Host "  Endereço selecionado: $selectedIP" -ForegroundColor Green
}

$url = "http://${selectedIP}:$port"
Write-Host ''
Write-Host ('=' * 68) -ForegroundColor DarkGreen
Write-Host '[4/4] SERVIDOR PRONTO' -ForegroundColor Green
Write-Host ('=' * 68) -ForegroundColor DarkGreen
Write-Host "  Pasta compartilhada: $($resolvedDirectory.Path)" -ForegroundColor Gray
Write-Host "  Endereço:            $url" -ForegroundColor Green
Write-Host ''
Write-Host '  Atenção: este servidor não usa autenticação nem HTTPS.' -ForegroundColor Yellow
Write-Host '  Compartilhe apenas arquivos apropriados para sua rede.' -ForegroundColor Yellow
Write-Host ''

$previousErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
try {
    & $python.Source -c "import qrcode; qr=qrcode.QRCode(border=1); qr.add_data('$url'); qr.make(); qr.print_ascii()" 2>$null
    $qrExitCode = $LASTEXITCODE
}
finally {
    $ErrorActionPreference = $previousErrorActionPreference
}
if ($qrExitCode -ne 0) {
    Write-Warning 'Não foi possível gerar o QR code. O servidor continuará; para habilitá-lo, instale o pacote com: python -m pip install qrcode'
}

Write-Host ''
Write-Host ('-' * 68) -ForegroundColor DarkCyan
Write-Host '  Servidor em execução. Pressione CTRL+C para encerrar.' -ForegroundColor Cyan
Write-Host ('-' * 68) -ForegroundColor DarkCyan
Write-Host ''

try {
    & $python.Source -m http.server $port --bind $selectedIP --directory $resolvedDirectory.Path
    $serverExitCode = $LASTEXITCODE
}
finally {
    Write-Host ''
    Write-Host 'Servidor encerrado.' -ForegroundColor Yellow
}

if ($serverExitCode -ne 0) {
    Write-Error "O servidor HTTP terminou com código de erro $serverExitCode. Verifique se a porta está em uso."
    exit $serverExitCode
}
