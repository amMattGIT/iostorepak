﻿using System;
using System.Diagnostics;
using System.IO;
using System.Windows.Forms;
using Newtonsoft.Json;
using System.Drawing;
using System.Collections.Generic;

namespace IOStorePak
{
    public partial class MainForm : Form
    {
        private string configFilePath = "config.json";

        public MainForm()
        {
            InitializeComponent();
            LoadConfig();
            ApplyTheme();

            // Attach the FormClosing event to ensure configuration is saved
            this.FormClosing += new FormClosingEventHandler(MainForm_FormClosing);
        }

        private void ApplyTheme()
        {
            if (chkDarkMode.Checked)
            {
                this.BackColor = Color.Black;
                this.ForeColor = Color.WhiteSmoke;
                foreach (Control control in this.Controls)
                {
                    if (control is TextBox || control is Button)
                    {
                        control.BackColor = Color.White;
                        control.ForeColor = Color.Black;
                    }
                    else
                    {
                        control.BackColor = Color.Black;
                        control.ForeColor = Color.WhiteSmoke;
                    }
                }
            }
            else
            {
                this.BackColor = Color.WhiteSmoke;
                this.ForeColor = Color.Black;
                foreach (Control control in this.Controls)
                {
                    if (control is TextBox || control is Button)
                    {
                        control.BackColor = Color.WhiteSmoke;
                        control.ForeColor = Color.Black;
                    }
                    else
                    {
                        control.BackColor = Color.WhiteSmoke;
                        control.ForeColor = Color.Black;
                    }
                }
            }
        }

        private void MainForm_FormClosing(object sender, FormClosingEventArgs e)
        {
            // Save the configuration when the form is closing
            SaveConfig();
        }

        private string BrowseForFolderModern()
        {
            using (OpenFileDialog openFileDialog = new OpenFileDialog())
            {
                openFileDialog.ValidateNames = false;
                openFileDialog.CheckFileExists = false;
                openFileDialog.CheckPathExists = true;
                openFileDialog.FileName = "Select Folder";
                openFileDialog.Filter = "Folders|\n";
                openFileDialog.InitialDirectory = Environment.GetFolderPath(Environment.SpecialFolder.MyComputer);

                if (openFileDialog.ShowDialog() == DialogResult.OK)
                {
                    return Path.GetDirectoryName(openFileDialog.FileName);
                }
            }
            return string.Empty;
        }

        private List<string> BrowseForMultipleFiles(string filter)
        {
            using (OpenFileDialog dialog = new OpenFileDialog())
            {
                dialog.Filter = filter;
                dialog.Multiselect = true; // Allow multi-selection
                if (dialog.ShowDialog() == DialogResult.OK)
                {
                    return new List<string>(dialog.FileNames);
                }
            }
            return new List<string>();
        }

        private string BrowseForFile(string filter)
        {
            using (OpenFileDialog dialog = new OpenFileDialog())
            {
                dialog.Filter = filter;
                if (dialog.ShowDialog() == DialogResult.OK)
                {
                    return dialog.FileName;
                }
            }
            return string.Empty;
        }

        private void ChooseSelectionType()
        {
            using (Form choiceForm = new Form())
            {
                choiceForm.Text = "Choose Selection Type";
                choiceForm.Size = new Size(240, 140);
                choiceForm.StartPosition = FormStartPosition.CenterParent;
                choiceForm.FormBorderStyle = FormBorderStyle.FixedDialog;
                choiceForm.MaximizeBox = false;
                choiceForm.MinimizeBox = false;

                Button btnSelectFiles = new Button() { Text = "Select Files", Location = new Point(20, 50), Size = new Size(80, 30) };
                btnSelectFiles.Click += (s, e) =>
                {
                    var selectedFiles = BrowseForMultipleFiles("Unreal Asset Files (*.uasset;*.uexp)|*.uasset;*.uexp");
                    txtAssetsPath.Text = string.Join(";", selectedFiles);
                    choiceForm.Close();
                };

                Button btnSelectFolder = new Button() { Text = "Select Folder", Location = new Point(120, 50), Size = new Size(80, 30) };
                btnSelectFolder.Click += (s, e) =>
                {
                    txtAssetsPath.Text = BrowseForFolderModern();
                    choiceForm.Close();
                };

                choiceForm.Controls.Add(btnSelectFiles);
                choiceForm.Controls.Add(btnSelectFolder);

                // Apply the theme to the choiceForm based on the dark mode state
                if (chkDarkMode.Checked)
                {
                    ApplyThemeToForm(choiceForm);
                }
                else
                {
                    ApplyLightThemeToForm(choiceForm);
                }

                choiceForm.ShowDialog();
            }
        }

        private void ApplyThemeToForm(Form targetForm)
        {
            targetForm.BackColor = Color.Black;
            targetForm.ForeColor = Color.WhiteSmoke;
            foreach (Control control in targetForm.Controls)
            {
                if (control is TextBox || control is Button)
                {
                    control.BackColor = Color.White;
                    control.ForeColor = Color.Black;
                }
                else
                {
                    control.BackColor = Color.Black;
                    control.ForeColor = Color.WhiteSmoke;
                }
            }
        }

        private void ApplyLightThemeToForm(Form targetForm)
        {
            targetForm.BackColor = Color.WhiteSmoke;
            targetForm.ForeColor = Color.Black;
            foreach (Control control in targetForm.Controls)
            {
                if (control is TextBox || control is Button)
                {
                    control.BackColor = Color.WhiteSmoke;
                    control.ForeColor = Color.Black;
                }
                else
                {
                    control.BackColor = Color.WhiteSmoke;
                    control.ForeColor = Color.Black;
                }
            }
        }

        private void LoadConfig()
        {
            if (File.Exists(configFilePath))
            {
                Config config = JsonConvert.DeserializeObject<Config>(File.ReadAllText(configFilePath));
                txtUEPath.Text = config.UnrealEnginePath;
                txtProjectPath.Text = config.UnrealProjectPath;
                chkCleanCooked.Checked = config.CleanCookedFolder;
                chkOpenOutput.Checked = config.OpenOutputFolder;
                chkDarkMode.Checked = config.DarkMode;
            }
        }

        private void SaveConfig()
        {
            Config config = new Config
            {
                UnrealEnginePath = txtUEPath.Text,
                UnrealProjectPath = txtProjectPath.Text,
                CleanCookedFolder = chkCleanCooked.Checked,
                OpenOutputFolder = chkOpenOutput.Checked,
                DarkMode = chkDarkMode.Checked
            };
            File.WriteAllText(configFilePath, JsonConvert.SerializeObject(config));
        }

        private void PackageAssets()
        {
            // Validate inputs
            if (string.IsNullOrEmpty(txtUEPath.Text) || string.IsNullOrEmpty(txtProjectPath.Text) || string.IsNullOrEmpty(txtAssetsPath.Text))
            {
                MessageBox.Show("Please provide all required paths.", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            string projectDirName = Path.GetFileNameWithoutExtension(txtProjectPath.Text);
            string cookedBasePath = Path.Combine(Path.GetDirectoryName(txtProjectPath.Text), "Saved", "Cooked", "WindowsNoEditor", projectDirName, "Content");
            string pakchunkPath = Path.Combine(Path.GetDirectoryName(txtProjectPath.Text), "Saved", "TmpPackaging", "WindowsNoEditor", $"pakchunk{txtChunkNumber.Text}.txt");

            // Clean the Cooked folder if the checkbox is checked
            if (chkCleanCooked.Checked && Directory.Exists(cookedBasePath))
            {
                Directory.Delete(cookedBasePath, true);
                Directory.CreateDirectory(cookedBasePath);
            }

            // Ensure the destination directories exist
            if (!Directory.Exists(cookedBasePath))
            {
                Directory.CreateDirectory(cookedBasePath);
            }

            // Initialize a list for the pakchunk file entries
            var pakchunkEntries = new List<string>();

            // Determine if user selected files or a folder
            var assetsPath = new List<string>();

            if (Directory.Exists(txtAssetsPath.Text))
            {
                // User selected a folder, gather all .uasset and .uexp files
                assetsPath.AddRange(Directory.GetFiles(txtAssetsPath.Text, "*.uasset", SearchOption.AllDirectories));
                assetsPath.AddRange(Directory.GetFiles(txtAssetsPath.Text, "*.uexp", SearchOption.AllDirectories));
            }
            else if (!string.IsNullOrEmpty(txtAssetsPath.Text))
            {
                // User selected individual files, split by ';' if multiple
                assetsPath.AddRange(txtAssetsPath.Text.Split(';'));
            }

            // Process each selected asset
            foreach (var asset in assetsPath)
            {
                // Ensure "Content" only appears once in the path
                int contentIndex = asset.IndexOf("Content", StringComparison.OrdinalIgnoreCase);
                string relativePath = asset.Substring(contentIndex + "Content".Length).TrimStart('\\', '/');

                string destinationPath = Path.Combine(cookedBasePath, relativePath);

                // Ensure the destination directory exists
                string destinationDir = Path.GetDirectoryName(destinationPath);
                if (!Directory.Exists(destinationDir))
                {
                    Directory.CreateDirectory(destinationDir);
                }

                // Copy the asset to the Cooked folder
                File.Copy(asset, destinationPath, true);

                // Add the full path (without extension) to the pakchunk list
                string pakchunkEntry = destinationPath.Replace(Path.GetExtension(asset), "");
                if (!pakchunkEntries.Contains(pakchunkEntry))
                {
                    pakchunkEntries.Add(pakchunkEntry);
                }
            }

            // Write the pakchunk entries to the .txt file
            File.WriteAllLines(pakchunkPath, pakchunkEntries);

            // Run the UAT command with visible window
            string runUAT = Path.Combine(txtUEPath.Text, "Engine", "Build", "BatchFiles", "RunUAT.bat");
            string arguments = $"BuildCookRun -project=\"{txtProjectPath.Text}\" -skipcook -pak -iostore -skipstage";
            var processInfo = new ProcessStartInfo(runUAT, arguments)
            {
                CreateNoWindow = false,  // Make sure this is set to false to show the window
                UseShellExecute = true,  // Set to true to make the window visible
            };
            var process = Process.Start(processInfo);
            process.WaitForExit();

            // Open the folder with the packaged assets if checkbox is checked
            if (chkOpenOutput.Checked)
            {
                string outputPath = Path.Combine(Path.GetDirectoryName(txtProjectPath.Text), "Saved", "StagedBuilds", "WindowsNoEditor", projectDirName, "Content", "Paks");
                Process.Start("explorer.exe", outputPath);
            }

            // Show a "Done" message box
            MessageBox.Show("Packaging Completed!", "IOStorePak", MessageBoxButtons.OK, MessageBoxIcon.Information);

            // Save the configuration on close
            SaveConfig();
        }

        private void btnPackage_Click(object sender, EventArgs e)
        {
            PackageAssets();
        }

        private void chkDarkMode_CheckedChanged(object sender, EventArgs e)
        {
            ApplyTheme();
        }

        private void txtChunkNumber_KeyPress(object sender, KeyPressEventArgs e)
        {
            // Allow only digits and control keys (like backspace)
            e.Handled = !char.IsDigit(e.KeyChar) && !char.IsControl(e.KeyChar);
        }

        private void btnBrowseUEPath_Click(object sender, EventArgs e)
        {
            txtUEPath.Text = BrowseForFolderModern();
        }

        private void btnBrowseProjectPath_Click(object sender, EventArgs e)
        {
            txtProjectPath.Text = BrowseForFile("Unreal Project Files (*.uproject)|*.uproject");
        }

        private void btnBrowseAssetsPath_Click(object sender, EventArgs e)
        {
            ChooseSelectionType();
        }
    }
}
