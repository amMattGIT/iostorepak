Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.IO
Add-Type -AssemblyName System.Web.Extensions
Add-Type -AssemblyName System.Drawing

# Path to the configuration file
$configFilePath = "config.json"

# Path to the icon file
$iconFilePath = "icon.ico"

# Function to load configuration
function Load-Config {
    if (Test-Path $configFilePath) {
        $configContent = Get-Content $configFilePath -Raw
        return [System.Web.Script.Serialization.JavaScriptSerializer]::new().DeserializeObject($configContent)
    }
    return @{}
}

# Function to save configuration
function Save-Config($config) {
    $jsonContent = [System.Web.Script.Serialization.JavaScriptSerializer]::new().Serialize($config)
    Set-Content -Path $configFilePath -Value $jsonContent
}

# Function to apply dark mode
function Apply-DarkMode {
    $form.BackColor = 'Black'
    $form.ForeColor = 'WhiteSmoke'
    $form.Controls | ForEach-Object {
        $_.BackColor = 'Black'
        $_.ForeColor = 'WhiteSmoke'
        if ($_.GetType().Name -eq 'TextBox') {
            $_.BackColor = 'White'
            $_.ForeColor = 'Black'
        } elseif ($_.GetType().Name -eq 'Button') {
            $_.BackColor = 'White'
            $_.ForeColor = 'Black'
        }
    }
}

# Function to apply light mode
function Apply-LightMode {
    $form.BackColor = 'WhiteSmoke'
    $form.ForeColor = 'Black'
    $form.Controls | ForEach-Object {
        $_.BackColor = 'WhiteSmoke'
        $_.ForeColor = 'Black'
        if ($_.GetType().Name -eq 'TextBox') {
            $_.BackColor = 'White'
            $_.ForeColor = 'Black'
        } elseif ($_.GetType().Name -eq 'Button') {
            $_.BackColor = 'WhiteSmoke'
            $_.ForeColor = 'Black'
        }
    }
}

# Apply dark mode to a given form
function Apply-DarkModeToForm {
    param ($targetForm)
    $targetForm.BackColor = 'Black'
    $targetForm.ForeColor = 'WhiteSmoke'
    $targetForm.Controls | ForEach-Object {
        $_.BackColor = 'Black'
        $_.ForeColor = 'WhiteSmoke'
        if ($_.GetType().Name -eq 'TextBox') {
            $_.BackColor = 'White'
            $_.ForeColor = 'Black'
        } elseif ($_.GetType().Name -eq 'Button') {
            $_.BackColor = 'White'
            $_.ForeColor = 'Black'
        }
    }
}

# Apply light mode to a given form
function Apply-LightModeToForm {
    param ($targetForm)
    $targetForm.BackColor = 'WhiteSmoke'
    $targetForm.ForeColor = 'Black'
    $targetForm.Controls | ForEach-Object {
        $_.BackColor = 'WhiteSmoke'
        $_.ForeColor = 'Black'
        if ($_.GetType().Name -eq 'TextBox') {
            $_.BackColor = 'White'
            $_.ForeColor = 'Black'
        } elseif ($_.GetType().Name -eq 'Button') {
            $_.BackColor = 'WhiteSmoke'
            $_.ForeColor = 'Black'
        }
    }
}

# Load the current configuration
$config = Load-Config

# Function to create the GUI
function Create-GUI {
    # Create the form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "IOStorePak"
    $form.Size = New-Object System.Drawing.Size(520,370) # Adjusted height for less space
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedDialog"  # This locks the UI from being resized
    $form.MaximizeBox = $false  # Disable maximize button
    $form.MinimizeBox = $true  # Allow minimize button

    # Add icon to the form (using the relative path)
    if (Test-Path $iconFilePath) {
        $form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon((Resolve-Path $iconFilePath))
    }

    # Unreal Engine Directory Label and TextBox
    $lblUEPath = New-Object System.Windows.Forms.Label
    $lblUEPath.Text = "Unreal Engine Directory:"
    $lblUEPath.Location = New-Object System.Drawing.Point(10,20)
    $lblUEPath.Size = New-Object System.Drawing.Size(140,20)
    $form.Controls.Add($lblUEPath)

    $txtUEPath = New-Object System.Windows.Forms.TextBox
    $txtUEPath.Location = New-Object System.Drawing.Point(150,20)
    $txtUEPath.Width = 250
    $txtUEPath.Text = $config.UnrealEnginePath
    $form.Controls.Add($txtUEPath)

    # Button to browse for Unreal Engine Directory
    $btnBrowseUE = New-Object System.Windows.Forms.Button
    $btnBrowseUE.Text = "Browse..."
    $btnBrowseUE.Location = New-Object System.Drawing.Point(410,18)
    $btnBrowseUE.Size = New-Object System.Drawing.Size(75,23)
    $btnBrowseUE.Add_Click({
        $folderBrowser = New-Object System.Windows.Forms.OpenFileDialog
        $folderBrowser.ValidateNames = $false
        $folderBrowser.CheckFileExists = $false
        $folderBrowser.CheckPathExists = $true
        $folderBrowser.FileName = "Folder Selection"
        if ($folderBrowser.ShowDialog() -eq "OK") {
            $txtUEPath.Text = [System.IO.Path]::GetDirectoryName($folderBrowser.FileName)
        }
    })
    $form.Controls.Add($btnBrowseUE)

    # Project File Label and TextBox
    $lblProjectPath = New-Object System.Windows.Forms.Label
    $lblProjectPath.Text = "Unreal Project File:"
    $lblProjectPath.Location = New-Object System.Drawing.Point(10,60)
    $lblProjectPath.Size = New-Object System.Drawing.Size(140,20)
    $form.Controls.Add($lblProjectPath)

    $txtProjectPath = New-Object System.Windows.Forms.TextBox
    $txtProjectPath.Location = New-Object System.Drawing.Point(150,60)
    $txtProjectPath.Width = 250
    $txtProjectPath.Text = $config.UnrealProjectPath
    $form.Controls.Add($txtProjectPath)

    # Button to browse for Project File
    $btnBrowseProject = New-Object System.Windows.Forms.Button
    $btnBrowseProject.Text = "Browse..."
    $btnBrowseProject.Location = New-Object System.Drawing.Point(410,58)
    $btnBrowseProject.Size = New-Object System.Drawing.Size(75,23)
    $btnBrowseProject.Add_Click({
        $fileBrowser = New-Object System.Windows.Forms.OpenFileDialog
        $fileBrowser.Filter = "Unreal Project Files (*.uproject)|*.uproject"
        if ($fileBrowser.ShowDialog() -eq "OK") {
            $txtProjectPath.Text = $fileBrowser.FileName
        }
    })
    $form.Controls.Add($btnBrowseProject)

    # Assets Folder Label and TextBox
    $lblAssetsPath = New-Object System.Windows.Forms.Label
    $lblAssetsPath.Text = "Select Assets to Package:"
    $lblAssetsPath.Location = New-Object System.Drawing.Point(10,100)
    $lblAssetsPath.Size = New-Object System.Drawing.Size(140,20)
    $form.Controls.Add($lblAssetsPath)

    $txtAssetsPath = New-Object System.Windows.Forms.TextBox
    $txtAssetsPath.Location = New-Object System.Drawing.Point(150,100)
    $txtAssetsPath.Width = 250
    $form.Controls.Add($txtAssetsPath)

    # Button to browse files or folders
    $btnChooseType = New-Object System.Windows.Forms.Button
    $btnChooseType.Text = "Browse..."
    $btnChooseType.Location = New-Object System.Drawing.Point(410,98)
    $btnChooseType.Size = New-Object System.Drawing.Size(75,23)
    $btnChooseType.Add_Click({
        # Create a form to choose between file or folder selection
        $choiceForm = New-Object System.Windows.Forms.Form
        $choiceForm.Text = "Choose Selection Type"
        $choiceForm.Size = New-Object System.Drawing.Size(240,140)
        $choiceForm.StartPosition = "CenterParent"
        $choiceForm.FormBorderStyle = "FixedDialog"
        $choiceForm.MaximizeBox = $false
        $choiceForm.MinimizeBox = $false

        # File selection button
        $btnSelectFiles = New-Object System.Windows.Forms.Button
        $btnSelectFiles.Text = "Select Files"
        $btnSelectFiles.Location = New-Object System.Drawing.Point(20,50)
        $btnSelectFiles.Size = New-Object System.Drawing.Size(80,30)
        $btnSelectFiles.Add_Click({
            $fileBrowser = New-Object System.Windows.Forms.OpenFileDialog
            $fileBrowser.Filter = "Unreal Asset Files (*.uasset;*.uexp)|*.uasset;*.uexp"
            $fileBrowser.Multiselect = $true
            if ($fileBrowser.ShowDialog() -eq "OK") {
                $txtAssetsPath.Text = $fileBrowser.FileNames -join ";"
                $choiceForm.Close()
            }
        })
        $choiceForm.Controls.Add($btnSelectFiles)

        # Folder selection button
        $btnSelectFolder = New-Object System.Windows.Forms.Button
        $btnSelectFolder.Text = "Select Folder"
        $btnSelectFolder.Location = New-Object System.Drawing.Point(120,50)
        $btnSelectFolder.Size = New-Object System.Drawing.Size(80,30)
        $btnSelectFolder.Add_Click({
            $folderBrowser = New-Object System.Windows.Forms.OpenFileDialog
            $folderBrowser.ValidateNames = $false
            $folderBrowser.CheckFileExists = $false
            $folderBrowser.CheckPathExists = $true
            $folderBrowser.FileName = "Folder Selection"
            if ($folderBrowser.ShowDialog() -eq "OK") {
                $txtAssetsPath.Text = [System.IO.Path]::GetDirectoryName($folderBrowser.FileName)
                $choiceForm.Close()
            }
        })
        $choiceForm.Controls.Add($btnSelectFolder)

        # Apply the theme to the choiceForm based on the dark mode state
        if ($chkDarkMode.Checked) {
            Apply-DarkModeToForm -targetForm $choiceForm
        } else {
            Apply-LightModeToForm -targetForm $choiceForm
        }

        $choiceForm.ShowDialog()
    })
    $form.Controls.Add($btnChooseType)

    # Chunk Number Label and TextBox
    $lblChunkNumber = New-Object System.Windows.Forms.Label
    $lblChunkNumber.Text = "Chunk Number:"
    $lblChunkNumber.Location = New-Object System.Drawing.Point(10,140)
    $lblChunkNumber.Size = New-Object System.Drawing.Size(140,20)
    $form.Controls.Add($lblChunkNumber)

    $txtChunkNumber = New-Object System.Windows.Forms.TextBox
    $txtChunkNumber.Location = New-Object System.Drawing.Point(150,140)
    $txtChunkNumber.Width = 50
    $form.Controls.Add($txtChunkNumber)

    # Restricting the input to numbers only
    $txtChunkNumber.add_KeyPress({
        param($sender, $e)
        # Allow only digits and control keys (like backspace)
        if (-not ($e.KeyChar -match '[\d\b]')) {
            $e.Handled = $true
        }
    })

    # Checkbox to clean the Cooked folder
    $chkCleanCooked = New-Object System.Windows.Forms.CheckBox
    $chkCleanCooked.Text = "Clean Cooked Folder Before Packaging"
    $chkCleanCooked.Location = New-Object System.Drawing.Point(150,170)
    $chkCleanCooked.Size = New-Object System.Drawing.Size(250,20)
    $form.Controls.Add($chkCleanCooked)

    # Checkbox to open the output folder
    $chkOpenOutput = New-Object System.Windows.Forms.CheckBox
    $chkOpenOutput.Text = "Open Output Folder After Packaging"
    $chkOpenOutput.Location = New-Object System.Drawing.Point(150,200)
    $chkOpenOutput.Size = New-Object System.Drawing.Size(250,20)
    $chkOpenOutput.Checked = if ($null -ne $config.OpenOutputFolder) { $config.OpenOutputFolder } else { $true }
    $form.Controls.Add($chkOpenOutput)

    # Dark mode toggle checkbox
    $chkDarkMode = New-Object System.Windows.Forms.CheckBox
    $chkDarkMode.Text = "Dark Mode"
    $chkDarkMode.Location = New-Object System.Drawing.Point(150,230)
    $chkDarkMode.Size = New-Object System.Drawing.Size(250,20)
    $chkDarkMode.Checked = if ($null -ne $config.DarkMode) { $config.DarkMode } else { $false } # Default is now unchecked (false)
    $chkDarkMode.Add_CheckedChanged({
        if ($chkDarkMode.Checked) {
            Apply-DarkMode
        } else {
            Apply-LightMode
        }
    })
    $form.Controls.Add($chkDarkMode)

    # Apply initial theme
    if ($chkDarkMode.Checked) {
        Apply-DarkMode
    } else {
        Apply-LightMode
    }

    # Button to start packaging process
    $btnPackage = New-Object System.Windows.Forms.Button
    $btnPackage.Text = "Package Assets"
    $btnPackage.Location = New-Object System.Drawing.Point(150,270)
    $btnPackage.Size = New-Object System.Drawing.Size(100,30)
    $form.Controls.Add($btnPackage)

    $btnPackage.Add_Click({
        # Get user input
        $uePath = $txtUEPath.Text
        $projectPath = $txtProjectPath.Text
        $selectedPath = $txtAssetsPath.Text
        $chunkNumber = $txtChunkNumber.Text
        $cleanCooked = $chkCleanCooked.Checked
        $openOutput = $chkOpenOutput.Checked

        # Get the project directory name without the .uproject extension
        $projectDirName = (Split-Path $projectPath -Leaf) -replace '\.uproject$', ''

        # Destination base paths
        $cookedBasePath = Join-Path (Split-Path $projectPath) "Saved\Cooked\WindowsNoEditor\$projectDirName\Content"
        $pakchunkPath = Join-Path (Split-Path $projectPath) "Saved\TmpPackaging\WindowsNoEditor\pakchunk$chunkNumber.txt"

        # Clean the Cooked folder if the checkbox is checked
        if ($cleanCooked -and (Test-Path $cookedBasePath)) {
            Remove-Item -Recurse -Force -Path $cookedBasePath
            New-Item -Path $cookedBasePath -ItemType Directory -Force
        }

        # Ensure the destination directories exist
        if (-not (Test-Path $cookedBasePath)) {
            New-Item -Path $cookedBasePath -ItemType Directory -Force
        }

        # Initialize a list for the pakchunk file entries
        $pakchunkEntries = @()

        # Determine if user selected files or a folder
        $assetsPath = @()

        if (Test-Path $selectedPath) {
            if ((Get-Item $selectedPath).PSIsContainer) {
                # User selected a folder, gather all .uasset and .uexp files
                $assetsPath = Get-ChildItem -Path $selectedPath -Recurse -Include *.uasset,*.uexp | ForEach-Object { $_.FullName }
            } else {
                # User selected individual files
                $assetsPath = $selectedPath -split ";"
            }
        }

        # Process each selected asset
        foreach ($asset in $assetsPath) {
            # Determine the relative path inside the Cooked folder
            $relativePath = $asset -replace ".*(Content|Game)\\", ""
            $assetBaseName = [System.IO.Path]::GetFileNameWithoutExtension($relativePath)

            # Check for the other related file (.uasset or .uexp)
            $relatedAssetPaths = @("$assetBaseName.uasset", "$assetBaseName.uexp") | ForEach-Object {
                $relatedFile = Join-Path (Split-Path $asset) $_
                if (Test-Path $relatedFile) {
                    $relatedFile
                }
            }

            # Full destination paths and copy both .uasset and .uexp if present
            foreach ($relatedAsset in $relatedAssetPaths) {
                $relatedRelativePath = $relatedAsset -replace ".*(Content|Game)\\", ""
                $destinationPath = Join-Path $cookedBasePath $relatedRelativePath
                $destinationDir = Split-Path $destinationPath -Parent

                # Ensure the destination directory exists
                if (-not (Test-Path $destinationDir)) {
                    New-Item -Path $destinationDir -ItemType Directory -Force
                }

                # Copy the asset to the Cooked folder
                Copy-Item -Path $relatedAsset -Destination $destinationPath
            }

            # Add the base path (without extension) to the pakchunk list
            $pakchunkEntry = (Join-Path $cookedBasePath $relativePath) -replace "\.(uasset|uexp)$", ""
            if ($pakchunkEntry -notin $pakchunkEntries) {
                $pakchunkEntries += $pakchunkEntry
            }
        }

        # Write the pakchunk entries to the .txt file
        $pakchunkEntries | Out-File -FilePath $pakchunkPath

        # Run the UAT command
        $runUAT = Join-Path $uePath "Engine\Build\BatchFiles\RunUAT.bat"
        $arguments = "BuildCookRun -project=`"$projectPath`" -skipcook -pak -iostore -skipstage"
        Start-Process -FilePath $runUAT -ArgumentList $arguments -NoNewWindow -Wait

        # Open the folder with the packaged assets if checkbox is checked
        if ($openOutput) {
            $outputPath = Join-Path (Split-Path $projectPath) "Saved\StagedBuilds\WindowsNoEditor\$projectDirName\Content\Paks"
            explorer.exe $outputPath
        }

        # Show a "Done" message box
        [System.Windows.Forms.MessageBox]::Show("Packaging Completed!", "IOStorePak", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    })

    # Attach the FormClosing event to save the configuration when the form is closed
    $form.Add_FormClosing({
        Save-Config @{
            UnrealEnginePath = $txtUEPath.Text
            UnrealProjectPath = $txtProjectPath.Text
            CleanCookedFolder = $chkCleanCooked.Checked
            OpenOutputFolder = $chkOpenOutput.Checked
            DarkMode = $chkDarkMode.Checked
        }
    })

    # Show the form
    $form.ShowDialog()
}

# Run the GUI
Create-GUI