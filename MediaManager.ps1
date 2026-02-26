Add-Type -AssemblyName System.Windows.Forms, System.Drawing

# --- Create the Main Window ---
$form = New-Object Windows.Forms.Form
$form.Text = "Media Matcher Pro"
$form.Size = New-Object Drawing.Size(650, 900)
$form.StartPosition = "CenterScreen"
$form.Font = New-Object Drawing.Font("Segoe UI", 9)

# Fix: Ensure the app closes completely without popups
$form.Add_FormClosing({
    $form.Tag = "Closing"
    [System.Windows.Forms.Application]::Exit()
})

# --- Folder Selection ---
$labelSource = New-Object Windows.Forms.Label
$labelSource.Text = "STEP 1: Source Folder (SD Card/Tablet)"; $labelSource.Location = "20,20"; $labelSource.AutoSize = $true
$txtSource = New-Object Windows.Forms.TextBox; $txtSource.Location = "20,45"; $txtSource.Width = 480
$btnSource = New-Object Windows.Forms.Button; $btnSource.Text = "Browse"; $btnSource.Location = "510,43"

$labelSearch1 = New-Object Windows.Forms.Label
$labelSearch1.Text = "STEP 2: Primary Archive"; $labelSearch1.Location = "20,90"; $labelSearch1.AutoSize = $true
$txtSearch1 = New-Object Windows.Forms.TextBox; $txtSearch1.Location = "20,115"; $txtSearch1.Width = 480
$btnSearch1 = New-Object Windows.Forms.Button; $btnSearch1.Text = "Browse"; $btnSearch1.Location = "510,113"

$labelSearch2 = New-Object Windows.Forms.Label
$labelSearch2.Text = "STEP 3: Secondary Archive (Optional)"; $labelSearch2.Location = "20,160"; $labelSearch2.AutoSize = $true
$txtSearch2 = New-Object Windows.Forms.TextBox; $txtSearch2.Location = "20,185"; $txtSearch2.Width = 480
$btnSearch2 = New-Object Windows.Forms.Button; $btnSearch2.Text = "Browse"; $btnSearch2.Location = "510,183"

# --- Expanded Filetype Selection ---
$labelTypes = New-Object Windows.Forms.Label
$labelTypes.Text = "STEP 4: Select Source Filetypes (Multi-select enabled)"; $labelTypes.Location = "20,235"; $labelTypes.AutoSize = $true

$flowPanel = New-Object Windows.Forms.FlowLayoutPanel
$flowPanel.Location = "20,260"; $flowPanel.Size = "570,80"; $flowPanel.FlowDirection = "LeftToRight"

$extsToCreate = @(".insp", ".insv", ".360", ".mp4", ".mov", ".jpg", ".png", ".heic", ".tif", ".dng")
$checkboxes = @()
foreach ($ext in $extsToCreate) {
    $c = New-Object Windows.Forms.CheckBox; $c.Text = $ext; $c.AutoSize = $true
    if ($ext -eq ".insp" -or $ext -eq ".insv") { $c.Checked = $true }
    $checkboxes += $c
}
$labelCustom = New-Object Windows.Forms.Label; $labelCustom.Text = " Custom:"; $labelCustom.AutoSize = $true
$txtCustomExt = New-Object Windows.Forms.TextBox; $txtCustomExt.Width = 60
$flowPanel.Controls.AddRange($checkboxes); $flowPanel.Controls.Add($labelCustom); $flowPanel.Controls.Add($txtCustomExt)

# --- Progress & Logging ---
$progressBar = New-Object Windows.Forms.ProgressBar
$progressBar.Location = "20,350"; $progressBar.Width = 570; $progressBar.Height = 20
$logBox = New-Object Windows.Forms.RichTextBox
$logBox.Location = "20,380"; $logBox.Width = 570; $logBox.Height = 250; $logBox.ReadOnly = $true; $logBox.Font = New-Object Drawing.Font("Consolas", 9)

# --- Control Buttons ---
$btnRun = New-Object Windows.Forms.Button
$btnRun.Text = "RUN SCAN"; $btnRun.Location = "20,650"; $btnRun.Width = 180; $btnRun.Height = 45; $btnRun.BackColor = "LightSteelBlue"

$btnClear = New-Object Windows.Forms.Button
$btnClear.Text = "CLEAR LOG"; $btnClear.Location = "215,650"; $btnClear.Width = 180; $btnClear.Height = 45

$btnSave = New-Object Windows.Forms.Button
$btnSave.Text = "SAVE LOG"; $btnSave.Location = "410,650"; $btnSave.Width = 180; $btnSave.Height = 45; $btnSave.Enabled = $false

$btnReadme = New-Object Windows.Forms.Button
$btnReadme.Text = "OPEN README / GUIDE"; $btnReadme.Location = "20,710"; $btnReadme.Width = 570; $btnReadme.Height = 35

# --- Functionality ---
$browseAction = { param($textBox) $dialog = New-Object Windows.Forms.FolderBrowserDialog; if($dialog.ShowDialog() -eq "OK") { $textBox.Text = $dialog.SelectedPath } }
$btnSource.Add_Click({ &$browseAction $txtSource })
$btnSearch1.Add_Click({ &$browseAction $txtSearch1 })
$btnSearch2.Add_Click({ &$browseAction $txtSearch2 })
$btnClear.Add_Click({ $logBox.Clear(); $btnSave.Enabled = $false })

$btnRun.Add_Click({
    if (!$txtSource.Text -or !$txtSearch1.Text) { [Windows.Forms.MessageBox]::Show("Please select Source and Archive 1."); return }
    $logBox.AppendText("Scan started: $(Get-Date -Format 'HH:mm:ss')`r`n")
    
    $selectedExts = @()
    foreach ($cb in $checkboxes) { if($cb.Checked){ $selectedExts += $cb.Text } }
    if($txtCustomExt.Text){ $selectedExts += $txtCustomExt.Text.Split(",").Trim() }
    
    $archives = @($txtSearch1.Text); if($txtSearch2.Text){$archives += $txtSearch2.Text}
    $files = Get-ChildItem -Path $txtSource.Text -Recurse | Where-Object { $selectedExts -contains $_.Extension.ToLower() }
    
    if ($files.Count -eq 0) { $logBox.AppendText("No matching files found.`r`n"); return }
    $progressBar.Maximum = $files.Count; $progressBar.Value = 0

    foreach ($file in $files) {
        if ($form.Tag -eq "Closing") { break } # Stop processing if user closes window
        $base = $file.BaseName; $origExt = $file.Extension.ToLower()
        $match = Get-ChildItem -Path $archives -Filter "$base.*" -Recurse -ErrorAction SilentlyContinue | 
                 Where-Object { $_.Extension.ToLower() -ne $origExt -and $_.Length -gt 0 }

        if ($match) {
            $logBox.SelectionColor = [Drawing.Color]::Green
            $logBox.AppendText("MATCHED: $($file.Name) -> $($match.Extension -join ', ')`r`n")
        } else {
            $logBox.SelectionColor = [Drawing.Color]::DarkOrange
            $logBox.AppendText("UNIQUE:  $($file.Name)`r`n")
        }
        $progressBar.Value++; [System.Windows.Forms.Application]::DoEvents()
    }
    if ($form.Tag -ne "Closing") { 
        $btnSave.Enabled = $true
        [Windows.Forms.MessageBox]::Show("Scan Complete!")
    }
})

$btnSave.Add_Click({
    $folderName = Split-Path $txtSource.Text -Leaf
    $saveDialog = New-Object Windows.Forms.SaveFileDialog
    $saveDialog.FileName = "Missing_Report_$($folderName)_$(Get-Date -Format 'yyyyMMdd').txt"
    if ($saveDialog.ShowDialog() -eq "OK") { $logBox.Text | Out-File -FilePath $saveDialog.FileName }
})

$btnReadme.Add_Click({
    $readmePath = "$env:TEMP\MediaMatcher_README.txt"
    $readmeText = "MEDIA MATCHER PRO - QUICK GUIDE`r`n-------------------------------`r`n1. SELECT SOURCE: The folder with your raw camera files (SD Card).`r`n2. SELECT ARCHIVE: Your backup/storage drives (H: Drive).`r`n3. SELECT FILETYPES: Choose formats to check. Multi-select is enabled.`r`n4. RUN SCAN: Matches filenames. If 'IMG_01.insv' has a corresponding 'IMG_01.mp4' on H:, it's a MATCH.`r`n5. SAVE LOG: Exports the missing list for manual processing."
    $readmeText | Out-File $readmePath
    Invoke-Item $readmePath
})

$form.Controls.AddRange(@($labelSource, $txtSource, $btnSource, $labelSearch1, $txtSearch1, $btnSearch1, $labelSearch2, $txtSearch2, $btnSearch2, $labelTypes, $flowPanel, $progressBar, $logBox, $btnRun, $btnClear, $btnSave, $btnReadme))

# Final Fix: Use the Exit thread to close cleanly
[void]$form.ShowDialog()