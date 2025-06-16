# Keep JPXDecoder used by PDFBox (used by read_pdf_text)
-keep class com.gemalto.jp2.** { *; }
-keep class com.tom_roush.pdfbox.** { *; }
-dontwarn com.gemalto.jp2.**
-dontwarn com.tom_roush.pdfbox.**
