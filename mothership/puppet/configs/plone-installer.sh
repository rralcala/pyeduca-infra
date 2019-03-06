#!/bin/bash
# Variables
#!/bin/bash
ZODB_FILE="Data.fs";
ZODB_ORIG="/var/lib/zope/var/$ZODB_FILE"
CONF_ORIG="/var/lib/zope/etc/zope.conf"
ZODB_PYEDU="/usr/local/plone/$ZODB_FILE"
CONF_PYEDU="/usr/local/plone/zope.conf"
PLONE_HOME="/usr/local/plone";
ZODB_DIR="/var/lib/zope/var";
URL_PLONE="http://oficina.paraguayeduca.org/~rgs/$ZODB_FILE";



echo "- Iniciando instalador: ";

grep -q "address \= 8000" $CONF_ORIG; 

if [[ $? != 0 ]]; then
	echo "cargando configuracion";
        cp $CONF_PYEDU $CONF_ORIG;
fi

if [ ! -f $PLONE_HOME/$ZODB_FILE ]; then
	echo "descargando archivo";
	PRUEBAS=1
	while [ $PRUEBAS -lt 5 ]; do 	
		cd $PLONE_HOME;
		wget -c $URL_PLONE;
		if [ $? -eq 0 ] ; then
			break;
		fi;
		let PRUEBAS=$PRUEBAS+1
	done
fi

if [ ! -f $ZODB_DIR/$ZODB_FILE ] && [ ! -z $PLONE_HOME/$ZODB_FILE ]; then
        echo "instalando base de datos"
        service zope stop;

        cp $PLONE_HOME/$ZODB_FILE $ZODB_DIR/$ZODB_FILE;
        chown zope.zope $ZODB_DIR/$ZODB_FILE;

        service zope start;
fi

echo " ..finalizado"
