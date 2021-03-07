function Diagnosis_Form(){
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 

    $imageName = "invalid"
    $imagePath = "invalid"

    # Set the size of your form
    [System.Windows.Forms.Application]::EnableVisualStyles();
    $form = New-Object System.Windows.Forms.Form
    $form.width = 500
    $form.height = 700
    $form.MaximizeBox = $true
    $form.WindowState = 'Maximized'
    $form.Text = "Diagnosis Selector"
  
    # Create a group that will contain your radio buttons
    $picBox = New-Object System.Windows.Forms.GroupBox
    $picBox.Location = '40,30'
    $picBox.size = '500,500'
    $picBox.text = "Specimen"

    #$img = [System.Drawing.Image]::Fromfile($file);
    $pic = New-Object Windows.Forms.PictureBox
    $pic.Dock = [System.Windows.Forms.DockStyle]::Fill
    #$pic.ImageLocation = $imagePath
    $pic.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::CenterImage
    $picBox.Controls.Add($pic)

    # Set the font of the text to be used within the form
    $Font = New-Object System.Drawing.Font("Times New Roman",12)
    $form.Font = $Font
 
    # Create a group that will contain your radio buttons
    $MyGroupBox = New-Object System.Windows.Forms.GroupBox
    $MyGroupBox.Location = '40,540'
    $MyGroupBox.size = '400,220'
    $MyGroupBox.text = "Diagnosis"

    Function onClick() {
        param($diagnosis)
        $NewLine = "{0},{1}" -f $imageName,$diagnosis
        $NewLine | add-content -path ($PSScriptRoot + "\results.csv")
        $form.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $form.Close()
    }
    
    # Create the collection of radio buttons
    $rb1 = New-Object System.Windows.Forms.RadioButton
    $rb1.Location = '20,40'
    $rb1.size = '350,20'
    $rb1.Checked = $false 
    $rb1.Text = "Option #1"
    $rb1.Add_Click({onClick -diagnosis 1})
 
    $rb2 = New-Object System.Windows.Forms.RadioButton
    $rb2.Location = '20,70'
    $rb2.size = '350,20'
    $rb2.Checked = $false
    $rb2.Text = "Option #2"
    $rb2.Add_Click({onClick -diagnosis 2})
 
    $rb3 = New-Object System.Windows.Forms.RadioButton
    $rb3.Location = '20,100'
    $rb3.size = '350,20'
    $rb3.Checked = $false
    $rb3.Text = "Option #3"
    $rb3.Add_Click({onClick -diagnosis 3})
 
    $rb4 = New-Object System.Windows.Forms.RadioButton
    $rb4.Location = '20,130'
    $rb4.size = '350,20'
    $rb4.Checked = $false
    $rb4.Text = "Option #4"
    $rb4.Add_Click({onClick -diagnosis 4})

    $SkipBtn = new-object System.Windows.Forms.Button
    $SkipBtn.Location = '200,760'
    $SkipBtn.Size = '100,40' 
    $SkipBtn.Text = 'Skip'
    $SkipBtn.Add_Click({
        $form.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $form.Close()
    })
 
    # Add all the GroupBox controls on one line
    $MyGroupBox.Controls.AddRange(@($rb1,$rb2,$rb3,$rb4))
 
    # Add all the Form controls on one line 
    $form.Controls.AddRange(@($picBox,$MyGroupBox,$SkipBtn))
 
    # Activate the form
    $form.Add_Shown({$form.Activate()})    
    
    # read CSV file
    $fileHash = @{}
    Import-Csv ($PSScriptRoot + "\results.csv") |
        ForEach-Object {
            $_
            $fileHash.Add($_.image,$_.diagnosis)
        }

    # Call the function
    Get-ChildItem $PSScriptRoot -Filter *.j* | Select-Object -Expand FullName |
    Foreach-Object {
        $name = Split-Path $_ -leaf
        if (-not $fileHash.ContainsKey($name)) {
            $imageName = $name
            $pic.ImageLocation = $_
            $dialogResult = $form.ShowDialog()
            $rb1.Checked = $false
            $rb2.Checked = $false
            $rb3.Checked = $false
            $rb4.Checked = $false
            if($dialogResult -ne "OK") {
                break
            }
        }
    }
}

Diagnosis_Form
