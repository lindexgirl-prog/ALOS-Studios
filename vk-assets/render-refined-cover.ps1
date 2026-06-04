Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = "Stop"
$outDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Color-Hex($hex) {
  return [System.Drawing.ColorTranslator]::FromHtml($hex)
}

function Brush($hex) {
  return [System.Drawing.SolidBrush]::new((Color-Hex $hex))
}

function Pen-Hex($hex, $width) {
  return [System.Drawing.Pen]::new((Color-Hex $hex), [float]$width)
}

function Font-Px($family, $size, $style) {
  return [System.Drawing.Font]::new($family, [float]$size, $style, [System.Drawing.GraphicsUnit]::Pixel)
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

function Draw-Text($g, $text, $font, $brush, $x, $y, $w, $h, $align, $valign) {
  $format = [System.Drawing.StringFormat]::new()
  $format.Alignment = [System.Drawing.StringAlignment]::$align
  $format.LineAlignment = [System.Drawing.StringAlignment]::$valign
  $format.Trimming = [System.Drawing.StringTrimming]::None
  $rect = [System.Drawing.RectangleF]::new([float]$x, [float]$y, [float]$w, [float]$h)
  $g.DrawString($text, $font, $brush, $rect, $format)
  $format.Dispose()
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

function Draw-Mark($g, $x, $y, $size, $white, $black) {
  $state = $g.Save()
  $g.TranslateTransform($x, $y)
  $scale = $size / 1200
  $g.ScaleTransform($scale, $scale)
  $g.TranslateTransform(600, 600)
  $g.ScaleTransform(1.08, 1.08)
  $g.TranslateTransform(-600, -555)
  Draw-OuterShape $g $white
  Draw-CenterCut $g $black
  $g.Restore($state)
}

function Draw-Cover1920 {
  $canvas = New-Canvas 1920 768
  $g = $canvas.Graphics
  $black = Brush "#050607"
  $white = Brush "#ffffff"
  $soft = Brush "#d9d9d9"
  $line = Pen-Hex "#ffffff" 2
  $g.FillRectangle($black, 0, 0, 1920, 768)

  $brandFont = Font-Px "Arial" 82 ([System.Drawing.FontStyle]::Bold)
  $h1Font = Font-Px "Arial" 36 ([System.Drawing.FontStyle]::Bold)
  $leadFont = Font-Px "Arial" 25 ([System.Drawing.FontStyle]::Bold)
  $metaFont = Font-Px "Arial" 22 ([System.Drawing.FontStyle]::Bold)

  $textX = 1030
  $g.DrawLine($line, $textX, 160, 1520, 160)
  Draw-Text $g "ALOS Studio" $brandFont $white $textX 194 720 96 Near Center
  Draw-Text $g "Лендинги + контент" $h1Font $white $textX 320 720 48 Near Center
  Draw-Text $g "Сайты, визуал и тексты для быстрых заявок." $leadFont $soft $textX 400 720 40 Near Center
  Draw-Text $g "t.me/aLoS_91  /  vk.ru/alos_studio" $metaFont $white $textX 492 720 38 Near Center
  $g.DrawLine($line, $textX, 562, 1606, 562)

  $brandFont.Dispose()
  $h1Font.Dispose()
  $leadFont.Dispose()
  $metaFont.Dispose()
  $line.Dispose()
  $soft.Dispose()
  $white.Dispose()
  $black.Dispose()
  Save-Canvas $canvas (Join-Path $outDir "alos-vk-cover-1920x768.png")
}

function Draw-Cover1590 {
  $canvas = New-Canvas 1590 530
  $g = $canvas.Graphics
  $black = Brush "#050607"
  $white = Brush "#ffffff"
  $soft = Brush "#d9d9d9"
  $line = Pen-Hex "#ffffff" 2
  $g.FillRectangle($black, 0, 0, 1590, 530)

  $brandFont = Font-Px "Arial" 58 ([System.Drawing.FontStyle]::Bold)
  $h1Font = Font-Px "Arial" 28 ([System.Drawing.FontStyle]::Bold)
  $leadFont = Font-Px "Arial" 20 ([System.Drawing.FontStyle]::Bold)
  $metaFont = Font-Px "Arial" 18 ([System.Drawing.FontStyle]::Bold)

  $textX = 880
  $g.DrawLine($line, $textX, 82, 1280, 82)
  Draw-Text $g "ALOS Studio" $brandFont $white $textX 110 560 70 Near Center
  Draw-Text $g "Лендинги + контент" $h1Font $white $textX 204 560 38 Near Center
  Draw-Text $g "Сайты, визуал и тексты для быстрых заявок." $leadFont $soft $textX 270 560 34 Near Center
  Draw-Text $g "t.me/aLoS_91  /  vk.ru/alos_studio" $metaFont $white $textX 352 560 30 Near Center
  $g.DrawLine($line, $textX, 416, 1330, 416)

  $brandFont.Dispose()
  $h1Font.Dispose()
  $leadFont.Dispose()
  $metaFont.Dispose()
  $line.Dispose()
  $soft.Dispose()
  $white.Dispose()
  $black.Dispose()
  Save-Canvas $canvas (Join-Path $outDir "alos-vk-cover-1590x530.png")
}

Draw-Cover1920
Draw-Cover1590
