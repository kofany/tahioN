#!/bin/bash
###############################################
##  IRC Bots Installation - NO UI VERSION    ##
##  Extracted from tahioN main script        ##
###############################################

# GITHUB_URL powinien być przekazany jako argument lub export z głównego skryptu
# Jeśli nie ma - ustaw default
if [ -z "$GITHUB_URL" ]; then
    GITHUB_URL="https://github.com"
fi

echo "Using GITHUB_URL: ${GITHUB_URL}"


do_post()
{
pushd /root/ >> /dev/null

git clone ${GITHUB_URL}/kofany/psotnic
if [ -d "/root/psotnic" ]; then
    cd /root/psotnic/

    # Sprawdź czy configure istnieje
    if [ -f "./configure" ]; then
        chmod +x ./configure
        ./configure

        if [ $? -eq 0 ]; then
            make dynamic

            if [ -f "/root/psotnic/bin/psotnic" ]; then
                mv /root/psotnic/bin/psotnic /bin/psotnic
                chmod +x /bin/psotnic
                cd /root
                rm -rf /root/psotni*
            else
                echo "ERROR: psotnic binary not found after compilation" >&2
                cd /root
                rm -rf /root/psotni*
            fi
        else
            echo "ERROR: psotnic ./configure failed" >&2
            cd /root
            rm -rf /root/psotni*
        fi
    else
        echo "ERROR: psotnic configure script not found" >&2
        cd /root
        rm -rf /root/psotni*
    fi
else
    echo "ERROR: Failed to clone psotnic from ${GITHUB_URL}/kofany/psotnic" >&2
fi

popd >/dev/null 2>&1
}


do_knb()
{
pushd /root/ >> /dev/null
git clone ${GITHUB_URL}/kofany/knb
if [ -d "/root/knb" ]; then
    cd /root/knb/src/

    # Sprawdź czy configure istnieje
    if [ -f "./configure" ]; then
        chmod +x configure
        ./configure --without-validator

        if [ $? -eq 0 ]; then
            make dynamic

            # Szukaj pliku binarnego knb (nazwa może się różnić)
            KNB_BINARY=$(find /root/knb -type f -name "knb-*-*" | head -1)

            if [ -n "$KNB_BINARY" ] && [ -f "$KNB_BINARY" ]; then
                cp "$KNB_BINARY" /bin/knb
                chmod +x /bin/knb
                cd /root
                rm -rf /root/knb*
            else
                echo "ERROR: knb binary not found after compilation" >&2
                cd /root
                rm -rf /root/knb*
            fi
        else
            echo "ERROR: knb ./configure failed" >&2
            cd /root
            rm -rf /root/knb*
        fi
    else
        echo "ERROR: knb configure script not found" >&2
        cd /root
        rm -rf /root/knb*
    fi
else
    echo "ERROR: Failed to clone knb from ${GITHUB_URL}/kofany/knb" >&2
fi

popd >/dev/null 2>&1
}


do_update()
{
pushd /root/ >> /dev/null
# Stałe
URL="${GITHUB_URL}/kofany/tahioN/raw/main/update.tar.gz"
DOWNLOAD_FILE="update.tar.gz"
UPDATE_DIR="update"

# Pobierz plik
wget -q "${URL}" -O "${DOWNLOAD_FILE}"

# Sprawdź czy plik został pobrany i ma rozmiar > 0
if [ -f "${DOWNLOAD_FILE}" ] && [ -s "${DOWNLOAD_FILE}" ]; then
    # Sprawdź czy to poprawny plik tar.gz
    if file "${DOWNLOAD_FILE}" | grep -q "gzip compressed"; then
        tar -xzf "${DOWNLOAD_FILE}"

        if [ $? -eq 0 ] && [ -d "/root/${UPDATE_DIR}" ]; then
            # Wejście do folderu update
            pushd /root/${UPDATE_DIR} >/dev/null 2>&1
            # Pobranie listy plików
            FILES_LIST=$(ls)

            # Przenoszenie plików
            for FILE in ${FILES_LIST}; do
                if [ -f "/bin/${FILE}" ]; then
                    rm -rf "/bin/${FILE}"
                fi
                cp "${FILE}" "/bin/${FILE}"
                chmod +x "/bin/${FILE}"
            done

            popd >/dev/null 2>&1
            rm -rf /root/upda*
        else
            echo "ERROR: Failed to extract update.tar.gz or update directory not found" >&2
            rm -f "${DOWNLOAD_FILE}"
        fi
    else
        echo "ERROR: Downloaded file is not a valid gzip archive (size: $(stat -f%z "${DOWNLOAD_FILE}" 2>/dev/null || stat -c%s "${DOWNLOAD_FILE}") bytes)" >&2
        rm -f "${DOWNLOAD_FILE}"
    fi
else
    echo "ERROR: Failed to download update.tar.gz from ${URL} or file is empty" >&2
    rm -f "${DOWNLOAD_FILE}"
fi

popd >/dev/null 2>&1
}

# Wywołaj funkcje które NIE działały - BEZ PROGRESS BAR!
echo "=== Installing Psotnic ==="
do_post
echo ""

echo "=== Installing KNB ==="
do_knb
echo ""

echo "=== Installing update binaries ==="
do_update
echo ""

echo "=== Bot installation complete ==="
