# YouTube-Downloader-Projekt

# --------------------------------------------------------------------------------
# GUI-Aufbau und Eingabevalidierung
# --------------------------------------------------------------------------------

# Laden der erforderlichen Assemblys
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Erstellung des Hauptformulars
$form = New-Object System.Windows.Forms.Form
$form.Text = "YouTube-Downloader"
$form.Size = New-Object System.Drawing.Size(400, 250) # Größe angepasst
$form.StartPosition = "CenterScreen"

# Textfeld für den YouTube-Link
$textBoxLink = New-Object System.Windows.Forms.TextBox
$textBoxLink.Location = New-Object System.Drawing.Point(10, 10)
$textBoxLink.Size = New-Object System.Drawing.Size(360, 20)
$form.Controls.Add($textBoxLink)

# Label für das Textfeld
$labelLink = New-Object System.Windows.Forms.Label
$labelLink.Location = New-Object System.Drawing.Point(10, 35)
$labelLink.Size = New-Object System.Drawing.Size(360, 20)
$labelLink.Text = "YouTube-Link eingeben:"
$form.Controls.Add($labelLink)

# Checkbox für Playlist-Download
$checkBoxPlaylist = New-Object System.Windows.Forms.CheckBox
$checkBoxPlaylist.Text = "Ganze Playlist herunterladen"
$checkBoxPlaylist.Location = New-Object System.Drawing.Point(10, 60)
$checkBoxPlaylist.Size = New-Object System.Drawing.Size(250, 20)
$checkBoxPlaylist.AutoSize = $true
$form.Controls.Add($checkBoxPlaylist)

# Radiobutton für Audio-Download
$radioButtonAudio = New-Object System.Windows.Forms.RadioButton
$radioButtonAudio.Location = New-Object System.Drawing.Point(10, 85)
$radioButtonAudio.Size = New-Object System.Drawing.Size(120, 20)
$radioButtonAudio.Text = "Nur Audio"
$form.Controls.Add($radioButtonAudio)

# Radiobutton für Video-Download
$radioButtonVideo = New-Object System.Windows.Forms.RadioButton
$radioButtonVideo.Location = New-Object System.Drawing.Point(130, 85)
$radioButtonVideo.Size = New-Object System.Drawing.Size(120, 20)
$radioButtonVideo.Text = "Video"
$radioButtonVideo.Checked = $true
$form.Controls.Add($radioButtonVideo)

# Textfeld für den Download-Ordner
$textBoxOutput = New-Object System.Windows.Forms.TextBox
$textBoxOutput.Location = New-Object System.Drawing.Point(10, 115)
$textBoxOutput.Size = New-Object System.Drawing.Size(250, 20)
$textBoxOutput.Text = "$PSScriptRoot\Downloads" # Standardordner
$form.Controls.Add($textBoxOutput)

# Button zum Auswählen des Download-Ordners
$buttonBrowse = New-Object System.Windows.Forms.Button
$buttonBrowse.Location = New-Object System.Drawing.Point(270, 115)
$buttonBrowse.Size = New-Object System.Drawing.Size(100, 20)
$buttonBrowse.Text = "Durchsuchen"
$form.Controls.Add($buttonBrowse)

# Ereignishandler für den "Durchsuchen"-Button
$buttonBrowse.Add_Click({
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.SelectedPath = $textBoxOutput.Text
    if ($folderBrowser.ShowDialog() -eq "OK") {
        $textBoxOutput.Text = $folderBrowser.SelectedPath
    }
})

# Button zum Starten des Downloads
$buttonDownload = New-Object System.Windows.Forms.Button
$buttonDownload.Location = New-Object System.Drawing.Point(10, 145)
$buttonDownload.Size = New-Object System.Drawing.Size(120, 30)
$buttonDownload.Text = "Download starten"
$form.Controls.Add($buttonDownload)

# Label für den Download-Status
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Location = New-Object System.Drawing.Point(10, 180)
$statusLabel.Size = New-Object System.Drawing.Size(360, 20)
$statusLabel.Text = ""
$form.Controls.Add($statusLabel)

# Eingabevalidierung (Beispiel)
function Validate-YouTubeLink {
    param($Link)
    # Hier könnte man eine komplexere Validierung einfügen
    if ($Link -match "^(http(s)?://)?(www\.)?youtube\.com/.*$") {
        return $true
    } else {
        return $false
    }
}

# --------------------------------------------------------------------------------
# yt-dlp Integration und Download-Logik
# --------------------------------------------------------------------------------

# Download-Logik
$buttonDownload.Add_Click({
    $youtubeLink = $textBoxLink.Text

    # Eingabevalidierung aufrufen
    if (-not (Validate-YouTubeLink $youtubeLink)) {
        $statusLabel.Text = "❌ Ungültiger YouTube-Link!"
        return
    }

    $ytdlpPath = "$PSScriptRoot\yt-dlp.exe"
    if (-not (Test-Path $ytdlpPath)) {
        $statusLabel.Text = "❌ yt-dlp.exe nicht gefunden!"
        return
    }

    try {
        $statusLabel.Text = "⏳ Download wird gestartet..."
        $form.Refresh()

        $outputPath = $textBoxOutput.Text # Download-Ordner aus Textfeld
        if (-not (Test-Path $outputPath)) {
            New-Item -ItemType Directory -Path $outputPath | Out-Null
        }

        if ($radioButtonAudio.Checked) {
            if ($checkBoxPlaylist.Checked) {
                $arguments = "--extract-audio --audio-format mp3 -o `"$outputPath\%(playlist_index)s - %(title)s.%(ext)s`" $youtubeLink"
            } else {
                $arguments = "--extract-audio --audio-format mp3 --no-playlist -o `"$outputPath\%(title)s.%(ext)s`" $youtubeLink"
            }

        } else {
            if ($checkBoxPlaylist.Checked) {
                $arguments = "-o `"$outputPath\%(playlist_index)s - %(title)s.%(ext)s`" $youtubeLink"
            } else {
                $arguments = "--no-playlist -o `"$outputPath\%(title)s.%(ext)s`" $youtubeLink"
            }

        }

        Start-Process -FilePath $ytdlpPath -ArgumentList $arguments -Wait -NoNewWindow

        $statusLabel.Text = "✅ Download abgeschlossen!"
    } catch {
        $statusLabel.Text = "❌ Fehler beim Herunterladen!"
        Write-Host "Fehler: $_"
    }
})

# --------------------------------------------------------------------------------
# Zusätzliche Funktionen (z.B. Fortschrittsanzeige) und Fehlerbehandlung
# --------------------------------------------------------------------------------

# (Hier könnten zusätzliche Funktionen wie erweiterte Fehlerbehandlung eingefügt werden)

# Anzeigen des Formulars
$form.Add_Shown({$form.Activate()})
[void]$form.ShowDialog()