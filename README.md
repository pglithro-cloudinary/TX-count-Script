````markdown
# 🧰 Cloudinary Transformation Counter

A lightweight Bash utility to measure **how many transformations** a given Cloudinary URL consumes.  
It can also **watch in real time** for any increases in transformation usage.

---

## ⚙️ Prerequisites

Before using the script, ensure you have:

1. **Cloudinary CLI** installed and authenticated:
   ```bash
   npm install -g @cloudinary/cli
   cld login
````

> You’ll need access to a Cloudinary account with **Admin API permissions**.

2. **jq** (for JSON parsing):

   ```bash
   brew install jq        # macOS
   sudo apt install jq    # Ubuntu/Debian
   ```

3. Confirm everything works:

   ```bash
   cld admin usage
   cld admin config
   ```

---

## 📦 Installation

1. **Save the script** as `txcount.sh`:

   ```bash
   nano txcount.sh
   ```

   Paste in the full script contents.

2. **Make it executable:**

   ```bash
   chmod +x txcount.sh
   ```

3. (Optional) **Add to your PATH** so it’s available globally:

   ```bash
   sudo mv txcount.sh /usr/local/bin/cld-transform-counter
   ```

---

## 🚀 Usage

### 🔹 One-Shot Mode (default)

Runs once — exits as soon as a transformation count increase is detected.

```bash
./txcount.sh "https://res.cloudinary.com/<cloud_name>/image/upload/w_500/sample.jpg"
```

**Example output:**

```
🔹 Fetching baseline transformation usage for cloud 'patrickg-assets'...
Baseline usage: 24934
🔹 Requesting transformation URL... done.
🔹 Polling for change in transformation usage...
✅ Transformation usage increased by 1.
```

---

### 🔁 Continuous Watch Mode

Keep the script running to monitor usage continuously.

```bash
./txcount.sh --watch "https://res.cloudinary.com/<cloud_name>/image/upload/w_500/sample.jpg"
```

**Example output:**

```
⏳ Current usage = 24936
✅ Transformation usage increased by 1 (total: 24937)
⏳ Current usage = 24937
✅ Transformation usage increased by 2 (total: 24939)
```

Press **Ctrl + C** to stop watching.

---

## 🧩 Notes

* The script automatically verifies that the provided URL matches your `cloud_name` from `cld admin config`.
* Default polling interval: **10 seconds**
  (You can adjust by editing the `INTERVAL` variable near the top of the script.)
* Works on macOS and most Linux distributions.
* Safe to re-run — it does not modify your Cloudinary data.

---

## 👥 Example Use Case

Use this tool to:

* Measure how many transformations are triggered by a specific URL or delivery chain.
* Verify optimisation behaviour when testing new transformations.
* Observe transformation counts during automated load or performance testing.

---

**Maintained by:** Cloudinary Solutions Engineering
**Author:** Patrick Glithro

```
