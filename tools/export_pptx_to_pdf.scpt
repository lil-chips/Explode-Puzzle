-- Export a PowerPoint .pptx to PDF.
-- Usage: osascript export_pptx_to_pdf.scpt /path/in.pptx /path/out.pdf

on run argv
	if (count of argv) is not 2 then
		error "Need input .pptx and output .pdf"
	end if
	set inPosix to item 1 of argv
	set outPosix to item 2 of argv

	set inFile to POSIX file inPosix
	set outFile to POSIX file outPosix

	tell application "Microsoft PowerPoint"
		activate
		open inFile
		set pres to active presentation
		save pres in outFile as save as PDF
		close pres saving no
	end tell
end run
