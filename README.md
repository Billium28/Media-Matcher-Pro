// https://virusscan.jotti.org // Virus scan comes back 0/13 perfect score.


🛡️ Media Matcher Pro: The Workflow Safety Net

Media Matcher Pro is a lightweight Windows utility designed for photographers, videographers, and action-cam enthusiasts. It acts as a final audit tool to ensure your raw media has been successfully accounted for in your archives before you format your memory cards.
🔍 Why use this?

We've all been there: you start a massive export or file transfer, and it gets interrupted. Or, you’ve been editing for hours and can’t remember if you actually moved every clip from your tablet/SD card to your permanent storage.

This tool solves "Backup Anxiety" by identifying exactly which files on your source drive do not have a corresponding version in your archive.
✨ Key Features

    Safety First: Only suggests deleting files once they are confirmed to exist (with actual data) in your destination.

    Smart Filename Matching: Matches files based on name, not extension. If DSC001.ARW exists as DSC001.jpg or DSC001.tif in your archive, it's marked as Matched.
wwwww
    Corruption Check: Automatically ignores 0-byte (corrupted/empty) files in your archive to ensure your backups are valid.

    Universal Format Support: Built-in filters for:

        Pro RAW: Sony (.ARW), Canon (.CR3), Nikon (.NEF), Fujifilm (.RAF), OM System (.ORF), Panasonic (.RW2).

        Action/Drone: Insta360 (.INSP, .INSV, .360), GoPro RAW (.GPR), Adobe (.DNG).

        Pro Video: .MP4, .MOV, .MXF, .MKV, .AVI.

    Dual-Archive Search: Scan two different backup drives (e.g., your NAS and your portable SSD) at the same time.

🚀 How to Use

    Select Source: Point the tool to your SD Card or "Import" folder.

    Select Archive: Point the tool to your main storage/project folders.

    Filter: Check the boxes for the specific formats you want to verify on your source.

    Run Scan: * GREEN (Confirmed): These files are safe. They exist in your archive.

        ORANGE (Unaccounted): These files are NOT in your archive. Export or move these before formatting your card!

    Save Log: Export a text report of the "Unaccounted" files for manual processing.

🛡️ Security & Trust

Because this application is a compiled PowerShell script and is unsigned, Windows Defender will likely display a "Windows protected your PC" (SmartScreen) warning.

To run the app:

    Click "More Info" in the popup.

    Click "Run anyway".

Full Transparency:

    This tool is open-source. You can review the full code in MediaManager 2.ps1 right here on GitHub.

    The app is Read-Only. It never moves, deletes, or modifies your original files.
