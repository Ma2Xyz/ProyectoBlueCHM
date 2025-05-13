#!/bin/bash
##############################################################
# Estos comandos son para que el POC funcione out of the box #
# no formarian parte del programa final en un escenario real #
##############################################################
pause() { echo "Presiona cualquier tecla para continuar..."; read -n 1 -s; }

rm logHashes.db

rm -rf textosPOC

mkdir textosPOC

clear

echo -e "sqlite3 logHashes.db CREATE TABLE logHashes (id INTEGER PRIMARY KEY AUTOINCREMENT, nombreArchivo TEXT NOT NULL, fecha TEXT NOT NULL, hash TEXT NOT NULL);\necho logOriginal > ejemplo.log"
sqlite3 logHashes.db "CREATE TABLE logHashes (id INTEGER PRIMARY KEY AUTOINCREMENT, nombreArchivo TEXT NOT NULL, fecha TEXT NOT NULL, hash TEXT NOT NULL);"

echo "logOriginal" > ejemplo.log

echo -e "\n> Primero creamos la base de datos en modo append-only, esto es un modo para la bbdd que solo deja añadir informacion, nunca borrar, adicionalmente creamos un archivo .log de ejemplo" 
pause
clear

echo -e "nombreArchivo=\"ejemplo.log\"\ntabla=\"logHashes.db\"\nfecha=\$(date +\"%Y-%m-%d %H:%M:%S\")\nhash=\$(sha256sum \"\$nombreArchivo\" | awk '{print \$1}')"
nombreArchivo="ejemplo.log"
tabla="logHashes.db"
fecha=$(date +"%Y-%m-%d %H:%M:%S")
hash=$(sha256sum "$nombreArchivo" | awk '{print $1}')

echo -e "\n> Con esto hemos creado las variables en las que indicaremos la ruta de la bbdd y la informacion que añadiremos a la misma"
pause
clear

echo "sqlite3 \$tabla INSERT INTO loghashes (nombreArchivo, fecha, hash) VALUES ('\$nombreArchivo', '\$fecha', '\$hash');"
sqlite3 $tabla "INSERT INTO loghashes (nombreArchivo, fecha, hash) VALUES ('$nombreArchivo', '$fecha', '$hash');"

echo -e "\n> Por ultimo insertamos la informacion en la tabla"
pause
clear

echo -e "validacion() {\n    ultimoHash=\$(sqlite3 \$tabla \"SELECT hash FROM logHashes WHERE nombreArchivo = '\$nombreArchivo';\")\n    hashActual=\$(sha256sum \"\$nombreArchivo\" | awk '{print \$1}')\n\n    if [ \"\$hashActual\" != \"\$ultimoHash\" ]; then\n        echo \"[WARNING] El log ha sido manipulado: \$nombreArchivo\"\n    else\n        echo \"[OK] El log está intacto: \$nombreArchivo\"\n    fi\n}"

validacion() {
    ultimoHash=$(sqlite3 $tabla "SELECT hash FROM logHashes WHERE nombreArchivo = '$nombreArchivo';")
    hashActual=$(sha256sum "$nombreArchivo" | awk '{print $1}')

    if [ "$hashActual" != "$ultimoHash" ]; then
        echo "[WARNING] El log ha sido manipulado: $nombreArchivo"
    else
        echo "[OK] El log está intacto: $nombreArchivo"
    fi
}

echo -e "\n> En esta funcion por un lado hemos extraido el ultimo hash registrado en la tabla y por el otro lado estamos recalculando manualmente el hash actual para compararlos"
pause
clear

echo "validacion"
validacion

echo -e "\n> Perfecto, como no se ha modificado nada, nos da el OK, ahora probemos a modificar el archivo y volver a ejecutar la validacion:"
pause
clear

echo -e "echo Modificado > ejemplo.log\n validacion"
echo "Modificado" > ejemplo.log
validacion

echo -e "\n> Ahora como hemos modificado el log, los valores hashes difieren y da el aviso, que podria ser por ejemplo un correo electronico o una notificacion en el sistema de monitorizacion"
pause
clear

echo -e "sqlite3 logHashes.db CREATE TABLE logHashes (id INTEGER PRIMARY KEY AUTOINCREMENT, nombreArchivo TEXT NOT NULL, fecha TEXT NOT NULL, hash TEXT NOT NULL);\necho logOriginal > ejemplo.log\n\n> Primero creamos la base de datos en modo append-only, esto es un modo para la bbdd que solo deja añadir informacion, nunca borrar, adicionalmente creamos un archivo .log de ejemplo\n\n\nnombreArchivo=\"ejemplo.log\"\ntabla=\"logHashes.db\"\nfecha=\$(date +\"%Y-%m-%d %H:%M:%S\")\nhash=\$(sha256sum \"\$nombreArchivo\" | awk '{print \$1}')\n\n> Con esto hemos creado las variables en las que indicaremos la ruta de la bbdd y la informacion que añadiremos a la misma\n\n\nsqlite3 \$tabla INSERT INTO loghashes (nombreArchivo, fecha, hash) VALUES ('\$nombreArchivo', '\$fecha', '\$hash');\n\n> Por ultimo insertamos la informacion en la tabla\n\n\nvalidacion() {\n    ultimoHash=\$(sqlite3 \$tabla \"SELECT hash FROM logHashes WHERE nombreArchivo = '\$nombreArchivo';\")\n    hashActual=\$(sha256sum \"\$nombreArchivo\" | awk '{print \$1}')\n\n    if [ \"\$hashActual\" != \"\$ultimoHash\" ]; then\n        echo \"[WARNING] El log ha sido manipulado: \$nombreArchivo\"\n    else\n        echo \"[OK] El log está intacto: \$nombreArchivo\"\n    fi\n}\n\n> En esta funcion por un lado hemos extraido el ultimo hash registrado en la tabla y por el otro lado estamos recalculando manualmente el hash actual para compararlos\n\n\nvalidacion\n[OK] El log está intacto: $nombreArchivo\n\n> Perfecto, como no se ha modificado nada, nos da el OK, ahora probemos a modificar el archivo y volver a ejecutar la validacion:\n\n\necho Modificado > ejemplo.log\n validacion\n[WARNING] El log ha sido manipulado: $nombreArchivo\n\n> Ahora como hemos modificado el log, los valores hashes difieren y da el aviso, que podria ser por ejemplo un correo electronico o cualquier una notificacion en el sistema de monitorizacion"
