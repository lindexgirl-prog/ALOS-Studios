Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = "Stop"
$outDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Color-Hex($hex) {
  return [System.Drawing.ColorTranslator]::FromHtml($hex)
}

function Brush($hex) {
  return [System.Drawing.SolidBrush]::new((Color-Hex $hex))
}

function New-Canvas($w, $h) {
  $bmp = [System.Drawing.Bitmap]::new($w, $h, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $bmp.SetResolution(96, 96)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
  $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  return @{ Bitmap = $bmp; Graphics = $g }
}

function Save-Canvas($canvas, $path) {
  $canvas.Graphics.Flush()
  $canvas.Bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
  $canvas.Graphics.Dispose()
  $canvas.Bitmap.Dispose()
}

function Draw-OuterShape($g, $white) {
  $shape = [System.Drawing.Drawing2D.GraphicsPath]::new()
  $shape.AddPolygon([System.Drawing.PointF[]]@(
    [System.Drawing.PointF]::new(414, 172),
    [System.Drawing.PointF]::new(800, 172),
    [System.Drawing.PointF]::new(692, 282),
    [System.Drawing.PointF]::new(905, 410),
    [System.Drawing.PointF]::new(782, 532),
    [System.Drawing.PointF]::new(684, 540),
    [System.Drawing.PointF]::new(676, 642),
    [System.Drawing.PointF]::new(580, 762),
    [System.Drawing.PointF]::new(430, 648),
    [System.Drawing.PointF]::new(438, 558),
    [System.Drawing.PointF]::new(258, 566),
    [System.Drawing.PointF]::new(230, 538),
    [System.Drawing.PointF]::new(284, 436),
    [System.Drawing.PointF]::new(340, 294),
    [System.Drawing.PointF]::new(450, 224)
  ))
  $g.FillPath($white, $shape)
  $shape.Dispose()
}

function Draw-CenterCut($g, $black) {
  $cut = [System.Drawing.Drawing2D.GraphicsPath]::new()
  $cut.StartFigure()
  $cut.AddBezier(548, 168, 541, 238, 538, 306, 512, 356)
  $cut.AddBezier(512, 356, 481, 416, 423, 438, 282, 448)
  $cut.AddBezier(282, 448, 380, 444, 430, 447, 458, 466)
  $cut.AddBezier(458, 466, 506, 499, 528, 580, 550, 682)
  $cut.AddBezier(550, 682, 560, 722, 570, 754, 580, 768)
  $cut.AddBezier(580, 768, 590, 736, 574, 650, 578, 600)
  $cut.AddBezier(578, 600, 582, 548, 598, 504, 632, 486)
  $cut.AddBezier(632, 486, 684, 456, 782, 434, 902, 418)
  $cut.AddBezier(902, 418, 788, 416, 698, 404, 646, 378)
  $cut.AddBezier(646, 378, 588, 349, 560, 284, 564, 172)
  $cut.AddBezier(564, 172, 560, 163, 552, 162, 548, 168)
  $cut.CloseFigure()
  $g.FillPath($black, $cut)
  $cut.Dispose()
}

function Draw-Logo($canvasSize, $outputName) {
  $canvas = New-Canvas $canvasSize $canvasSize
  $g = $canvas.Graphics
  $black = Brush "#050607"
  $white = Brush "#ffffff"
  $g.FillRectangle($black, 0, 0, $canvasSize, $canvasSize)

  $state = $g.Save()
  $scale = $canvasSize / 1200
  $g.ScaleTransform($scale, $scale)
  $g.TranslateTransform(600, 600)
  $g.ScaleTransform(1.08, 1.08)
  $g.TranslateTransform(-600, -555)
  Draw-OuterShape $g $white
  Draw-CenterCut $g $black
  $g.Restore($state)

  $white.Dispose()
  $black.Dispose()
  Save-Canvas $canvas (Join-Path $outDir $outputName)
}

Draw-Logo 1200 "alos-vk-avatar-1200.png"
Draw-Logo 2400 "alos-logo-refined-2400.png"
Draw-Logo 512 "alos-logo-refined-512.png"
