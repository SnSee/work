; 读文件
rfp = infile("tmp.txt")
; 按行读取
while(gets(line fp)
    println(line)
)
; 按字符读取
while(char = getc(fp)
    println(char)
)
close(rfp)

; 写文件
wfp = outfile("tmp.txt")
fprintf(wfp "message: ")
fprintf(wfp "%d %d" 1 2)
close(wfp)
