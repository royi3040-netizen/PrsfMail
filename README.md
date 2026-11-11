# PrsfMail

PrsfMail is a planned, independently customizable mail client based on [MailCraft](https://github.com/UCS-Care-Group/mailcraft).

## מצב הפרויקט
כרגע זהו **מעטפת בנייה עבור PrsfCompilation** ולא עותק מלא של MailCraft. בעת בנייה, אם עדיין לא הוכנס קוד מקור מקומי, המתכון מוריד את קוד המקור הציבורי של MailCraft לסביבת העבודה הזמנית של PrsfCompilation. לכן שינויי PrsfMail עתידיים מחייבים לשמור קוד מקור קבוע בתיקיית `source/mailcraft` במאגר זה.

## קימפול בעזרת PrsfCompilation
1. הורד את המאגר הזה באמצעות GitHub Desktop למחשב.
2. פתח PrsfCompilation והוסף את תיקיית PrsfMail כפרויקט.
3. השתמש בכפתור Windows או Server; ייטענו המתכונים מקובץ `.prsfcompilation.json`.
4. Windows מייצר חבילת ZIP ניידת עם `PrsfMail.exe`.
5. Server מייצר ZIP של אתר סטטי (WASM). **Gmail דרך IMAP/SMTP אינו נתמך בדפדפן** בפרויקט המקורי; זו אינה גרסת שרת דואר.

## הגדרות
- Windows: `packaging/prsfcompilation/build-windows.ps1`
- Server/Web: `packaging/prsfcompilation/build-server.ps1`
- מקור: `source/mailcraft` אם קיים, אחרת הורדה זמנית אוטומטית
- זמניים ותוצר: נתיבים שמנוהלים על ידי PrsfCompilation ב־DATA
- עיצוב, תרגום לעברית, RTL/LTR ושינוי שם פנימי: **מתוכננים, לא מומשו עדיין**.

לא מריצים קימפול אוטומטית בעת הורדה. על מנת לשמור שינויי קוד משלך יש להכניס את קוד MailCraft לתוך מאגר PrsfMail, לשמר את הרישיונות, ולבצע התאמות בנפרד.

## רישיון
MailCraft מופץ תחת MIT ו־Apache-2.0; יש לשמר הודעות רישוי וזכויות יוצרים בעת הפצת גרסה נגזרת. לפני הפצה יש לבדוק גם רישיונות של נכסים ותלויות.


## עברית וכיוון ממשק (PrsfMail)
- בחלון **File → Options → Language** ניתן לבחור **עברית (תצוגה מקדימה)** או English. התרגום העברי נמצא ב-`source/mailcraft/crates/i18n/po/he.po` ומכסה כרגע מונחים מרכזיים בלבד; טקסטים שעדיין לא תורגמו נשארים באנגלית.
- בהגדרה נפרדת **File → Options → Direction** ניתן לבחור **מימין לשמאל** או **משמאל לימין**, ללא תלות בשפה. ההעדפה נשמרת כחלק מהגדרות הממשק.
- במצב RTL חלוניות הניווט והתיקיות ורשימת ההודעות עוברות לצד הנגדי. **זו תמיכת RTL ראשונית ולא היפוך מלא של כל הרכיבים**: חלק מהכותרות, חלונות הדיאלוג והטקסטים עדיין צריכים התאמה.
- על Windows נטען גופן המערכת בהתאם למנגנון הקיים; נדרשת בדיקה ויזואלית שהעברית מוצגת היטב.
- לא בוצעו קימפול או בדיקות הרצה לאחר השינויים.
