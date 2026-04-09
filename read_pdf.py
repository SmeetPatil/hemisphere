import PyPDF2
try:
    reader = PyPDF2.PdfReader('Product Requirements Document (PRD)_ Project Hemisphere (2).pdf')
    text = '\n'.join([page.extract_text() for page in reader.pages])
    with open('prd.txt', 'w', encoding='utf-8') as f:
        f.write(text)
    print("Done")
except Exception as e:
    print("Error:", e)
