# convert all the PDFs to text
Dir.chdir("town-council-minutes")
files = Dir.glob("*.pdf")

files.each do |f|
  system("pdftotext "+f)
end