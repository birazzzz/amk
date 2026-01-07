
$port = 3000
$basePath = "d:\Code\Impact Token"
$url = "http://localhost:$port/"

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($url)

try {
    $listener.Start()
    Write-Host "🚀 Server started at $url"
    Write-Host "Press Ctrl+C to stop"

    while ($listener.IsListening) {
        try {
            $context = $listener.GetContext()
            $request = $context.Request
            $response = $context.Response

            $relativePath = $request.Url.LocalPath.TrimStart('/')
            if ([string]::IsNullOrWhiteSpace($relativePath)) {
                $relativePath = "index.html"
            }

            $filePath = Join-Path $basePath $relativePath
            
            if (Test-Path $filePath -PathType Leaf) {
                $extension = [System.IO.Path]::GetExtension($filePath).ToLower()
                $contentType = switch ($extension) {
                    ".html" { "text/html" }
                    ".css" { "text/css" }
                    ".js" { "text/javascript" }
                    ".png" { "image/png" }
                    ".jpg" { "image/jpeg" }
                    ".jpeg" { "image/jpeg" }
                    ".svg" { "image/svg+xml" }
                    ".json" { "application/json" }
                    default { "application/octet-stream" }
                }

                $content = [System.IO.File]::ReadAllBytes($filePath)
                $response.ContentType = $contentType
                $response.ContentLength64 = $content.Length
                $response.OutputStream.Write($content, 0, $content.Length)
            }
            else {
                $response.StatusCode = 404
                $buffer = [System.Text.Encoding]::UTF8.GetBytes("404 - Not Found")
                $response.ContentLength64 = $buffer.Length
                $response.OutputStream.Write($buffer, 0, $buffer.Length)
            }
            $response.Close()
        }
        catch {
            Write-Host "Error handling request: $_"
        }
    }
}
finally {
    $listener.Stop()
}
