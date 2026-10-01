> A simple website for university like works 

--- 

# The technology we gonna use.

1. Webpage
  - HTML
  - CSS
  - JavaScript
2. Backend
  - Python
3. Database
  - Mariadb/MySQL
4. Version Control
  - git
5. Source Code place
  - github

---

> How to use this project for local testing

1. Clone this repository

```bash
git clone https://github.com/0exu/dr0idx.git
```

2. Navigate to the `web-content` folder

```bash
cd web-content/
```

3. Now create the `venv` virtual environment for python

```bash
python3 -m venv venv
```

4. Now activate the `venv`

```bash
source venv/bin/activate.fish (for fish shell)
source venv/bin/activate.bash (for bash shell)
```

5. Now install `requirements` for backend

```bash
pip install -r backend/requirement.txt
```

6. Now copy the previous `.env.example` to **backend** folder as `.env`

```bash
cp ../.env.example backend/.env
```

7. Now edit the `.env` file according your system db working like **username**, **password**, **port is always 3306** and **database name not table**

```bash
micro backend/.env
or
vscode (optional)
```
8. Now start the **localhost** using **python**

```bash
python3 -m http.server 5000
```

9. Now start the **mariadb/mysql** service if not running (Don't know about the windows)

```bash
systemctl start mariadb
```

10. Now run the **backend**

```bash
python3 backend/server.py
```

11. Now your **local** instance is ready for testing. You can visit that to any browser in this url `http://127.0.0.1:5000`.
12. Now if you are **ngrok** user or **cloudflare** user then do this for hosting (This is not the production mode)

```bash
cloudflared tunnel --url localhost:5000
or
ngrok http 5000
```
---

> This is still under devlopment so always try to pull every day. using `git pull`.
