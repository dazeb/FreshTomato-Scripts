**Manual (no TTB)**
This method is the traditional one and assumes you have access to some sort of external storage e.g., CIFS or USB. In this example, we'll use CIFS and `mytheme.zip`:

1. Download `mytheme.zip` into `cifs1`. To do so, refer to the standard URL `https://freshtomato.org/tomatothemebase/wp-content/uploads/` + theme name + `.zip`

   ```bash
   cd /cifs1
   wget -O theme.zip https://freshtomato.org/tomatothemebase/wp-content/uploads/mytheme.zip
   ```

2. Extract your archive into `cifs1`:

   ```bash
   unzip -o mytheme.zip -d /cifs1/mytheme
   ```

3. Rename the `.css` file:

   ```bash
   mv /cifs1/mytheme/mytheme.css /cifs1/mytheme/custom.css
   ```

4. Copy the files into Tomato (RAM):

   ```bash
   cp -r /cifs1/mytheme/* /var/wwwext/
   ```

5. Log into your Tomato and go into `Administration` > `Admin access` > `Colour scheme`.

6. Select the option `Custom (ext/custom.css)`.

7. Save.

8. Reload your Tomato interface in the browser.

9. If you want the theme to load from `cifs1` automatically (e.g., after a reboot), add the following line as per point 4) in the `Administration` > `CIFS Client` > `Execute When Mounted`:

   ```bash
   cp -r /cifs1/mytheme/* /var/wwwext/
   ```
