# הדגמות Git לקורס - Mission Control for Code

שלוש הדגמות קצרות (3-5 דקות כל אחת) שהופכות את שקפי ה-Worktrees, ה-Safety Net וה-OpenSpec למשהו שרואים בטרמינל.
כל סקריפט עוצר בין שלבים (Enter) כדי שאפשר יהיה להסביר. להרצה רצופה בלי עצירות: `DEMO_AUTO=1 ./demo1_worktrees.sh`

**הורדה:**
```bash
git clone https://github.com/yuliabk/ai-dev-git-demos.git
cd ai-dev-git-demos
chmod +x *.sh
```

**דרישות:** Git 2.40+, Bash (ב-Windows: Git Bash או WSL), Node.js 20+.

---

## הדגמה 1 - Worktrees: כמה סוכנים במקביל
**שקפים:** 18, 19, 21 ושקף ההסבר החדש על Worktree
```bash
./demo1_worktrees.sh            # יוצר ~/worktree-demo
```
**מה רואים:**
1. פרויקט רגיל עם main.
2. `git worktree add` יוצר שתי תיקיות נוספות, כל אחת על branch משלה, מאותו repo.
3. "סוכן 1" ו"סוכן 2" עושים commits במקביל, והתיקייה הראשית לא מושפעת.
4. merge ותרשים `git log --graph` שמראה את שני הקווים המקבילים.

**להדגמה חיה עם סוכנים:** אחרי שלב 3, פותחים שני טרמינלים, `cd ../shop-backend` ו-`cd ../shop-tests`, ומריצים בכל אחד `claude` או `codex` עם משימה אחרת.

---

## הדגמה 2 - הגנה על main
**שקפים:** 22, 25, 26
```bash
./demo2_protect_main.sh         # חלק א: מקומי לגמרי, יוצר ~/protect-main-demo
cd ~/protect-main-demo
bash /path/to/git-demos/demo2_github_setup.sh # חלק ב: אופציונלי, GitHub אמיתי (דורש gh auth login)
```
**חלק א (מקומי):**
1. ניסיון commit ישירות על main - נחסם (git hook).
2. עבודה על branch ששוברת לוגיקה - הטסטים נכשלים, כמו CI אדום.
3. מימוש נכון עם טסט חדש - ירוק, ו-`git diff main` מראה לאדם בדיוק מה לבדוק.

**חלק ב (GitHub):** יוצר repo פרטי, מפעיל Branch Protection (PR חובה, אישור אחד, בדיקת CI בשם `test`), ופותח PR עם טסט שנכשל. בדפדפן רואים שכפתור ה-Merge חסום.

---

## הדגמה 3 - OpenSpec על פרויקט קיים
**שקפים:** 10, 11, 12 ושקף ההסבר החדש על Delta Spec
```bash
npm install -g @fission-ai/openspec
./demo3_openspec.sh             # יוצר ~/openspec-demo
```
**מה רואים:**
1. **Main Spec** - מפרט ההתחברות הקיים.
2. **Propose** - שינוי מוצע (הוספת 2FA): proposal, tasks ו-**Delta Spec** שמכיל רק `ADDED Requirements`.
3. **Apply** - המשימות מסומנות כבוצעו.
4. **Archive** - `openspec archive` ממזג את ה-Delta לתוך ה-Main Spec ושומר את השינוי בארכיון עם תאריך.

**להדגמה חיה עם סוכן:** בפרויקט אחרי `openspec init`, בתוך Claude Code או Codex: `/opsx:propose "add 2FA"`, אחר כך `/opsx:apply`, ובסוף `/opsx:archive`.

> נבדק עם OpenSpec 1.13.0. הפקודות בתוך הסוכן הן `/opsx:apply` (עם נקודתיים), ולא `/opsx-apply` כמו שכתוב בשקף 12.


---

**בדיקה אוטומטית:** בכל push, GitHub Actions מריץ את שלוש ההדגמות (לשונית Actions). אם משהו נשבר, רואים זאת שם.

נבנה ע"י Yulia Brichka | Gradient AI
