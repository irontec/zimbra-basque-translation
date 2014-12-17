#!/bin/bash
# Script cuya función es añadir los archivos con la traducción al Euskera en Zimbra Collaboration Server Open Source Edition (8.0.6_GA_5922)#
# Tambien podremos setear variables importantes en la configuració del servidor Zimbra (relacionadas con la visualización del idioma implementado) # 

echo ""
echo " ##################################################################################"
echo " ###										###"
echo " ###			-- Deploy Zimbra Euskera --				###"
echo " ###										###"
echo " ###	Zimbra Collaboration Server Open Source Edition (8.0.6_GA_5922)		###"
echo " ###										###"
echo " ###		Autor: Irontec S.L.		Fecha: 28-04-2014		###"
echo " ###		Contacto: sistemas@irontec.com					###"
echo " ###										###"
echo " ##################################################################################"
echo ""

num1=0
while [ $num1 == 0 ]
do
        read -p "· ¿Desea implementar el idioma Euskera en su servidor Zimbra? [S/N]: " INSTALAR;
        if [ "$INSTALAR" == "S" ] || [ "$INSTALAR" == "s" ]; then
		# Damos permisos a los archivos de idioma.
		/bin/chmod 664 messages/*
		/bin/chmod 664 keys/*
		/bin/chmod 664 msgs/*

		# Cambiamos la auditoria de los ficheros de idioma.
		/bin/chown zimbra:zimbra messages/*
		/bin/chown zimbra:zimbra keys/*
		/bin/chown zimbra:zimbra msgs/*

		# Copiamos los archivos de idioma a sus lugares correspondientes.
		cp -fp messages/* /opt/zimbra/jetty/webapps/zimbra/WEB-INF/classes/messages/
		cp -fp keys/* /opt/zimbra/jetty/webapps/zimbra/WEB-INF/classes/keys/
		cp -fp msgs/* /opt/zimbra/conf/msgs/

		cp -fp messages/* /opt/zimbra/jetty/webapps/zimbraAdmin/WEB-INF/classes/messages/
		cp -fp keys/* /opt/zimbra/jetty/webapps/zimbraAdmin/WEB-INF/classes/keys/

		# Añadir localeName_eu = Euskera en los ficheros ZmMsg_XX.properties propios de cada idioma.

		for file1 in /opt/zimbra/jetty/webapps/zimbra/WEB-INF/classes/messages/ZmMsg_*; 
		do
		echo "localeName_eu = Euskera" >> $file1;
		done

		for file2 in /opt/zimbra/jetty/webapps/zimbraAdmin/WEB-INF/classes/messages/ZmMsg_*;
                do
                echo "localeName_eu = Euskera" >> $file2;
                done

		# Copiamos los archivos de ayuda.
		su - zimbra -c "cp -fpr /opt/zimbra/jetty/webapps/zimbra/help/en_US/ /opt/zimbra/jetty/webapps/zimbra/help/eu"
		su - zimbra -c "cp -fpr /opt/zimbra/jetty/webapps/zimbraAdmin/help/en_US/ /opt/zimbra/jetty/webapps/zimbraAdmin/help/eu"

                echo "";
                echo " Idioma implementado correctamente";
                echo " Nota: En ciertos apartados de zimbra que dependen de zimlets, el idioma mostrado puede no ser el Euskera. La traducción de los zimlets no entra dentro del alcance de este proyecto.";
                echo "";
                num1=1;
        fi
        if [ "$INSTALAR" == "N" ] || [ "$INSTALAR" == "n" ]; then
                echo "";
                echo " Instalación omitida. Salimos del asistente.";
                echo "";
                num1=1;
		exit;
        fi
done

num2=0
while [ $num2 == 0 ]
do
	read -p "· ¿Desea configurar el Euskera como idioma predeterminado para todos los usuarios en la interfaz de Zimbra? (Siempre y cuando usen el CoS default) [S/N]: " DEFAULT;
	if [ "$DEFAULT" == "S" ] || [ "$DEFAULT" == "s" ]; then
		# Seteamos zimbraPrefLocale al euskera
		su - zimbra -c "zmprov mc default zimbraPrefLocale eu"
        	echo "";
		echo " Establecido el Euskera como idioma predeterminado en la interfaz de Zimbra.";
		echo " Nota: Si el usuario realiza una configuración personalizada del idioma desde sus preferencias, su elección estará por encima de la configuración por defecto del servidor.";
		echo " Nota: Si el CoS es custom/específico para tus grupos de usuarios, deberas cambiarlo manualmente con el comando: 'zmprov mc NONMBRE_DE_TU_CoS zimbraPrefLocale eu'" 
		echo "";
		num2=1;
	fi
	if [ "$DEFAULT" == "N" ] || [ "$DEFAULT" == "n" ]; then
		echo "";
        	echo " Paso omitido.";
		echo "";
		num2=1;
	fi
done

num3=0
while [ $num3 == 0 ]
do
	read -p "· Para que el nuevo idioma esté disponible es necesario reiniciar el servicio Zimbra ¿Desea reiniciarlo ahora? [S/N]: " REINICIO;
	if [ "$REINICIO" == "S" ] || [ "$REINICIO" == "s" ]; then
		echo ""
		echo " Reiniciando el servicio Zimbra. Este proceso puede durar un par de minutos...";
		echo ""
		# Reiniciamos el servicio Zimbra, realizando varias esperas para que finalicen correctamente los servicios ^^
		su - zimbra -c "zmcontrol stop";
		sleep 10;
		echo "";
		su - zimbra -c "zmcontrol startup";
		sleep 10;
		echo "";
		echo " Servicio Zimbra reiniciado. Instalación completada.";
		echo "";
		num3=1;
	fi
	if [ "$REINICIO" == "N" ] || [ "$REINICIO" == "n" ]; then
		echo "";
		echo " Ha decidido omitir el reinicio del servicio Zimbra. Recuerde que el nuevo idioma no estará disponible hasta que el servicio Zimbra sea reiniciado.";
		echo "";
		num3=1;
	fi
done

