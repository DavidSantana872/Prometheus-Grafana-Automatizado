section() {
  COLOR=$2
  echo ""
  echo -e "${COLOR}----------------------------------------------------------------------"
  echo -e "$1"
  echo "----------------------------------------------------------------------"
  echo ""
}
option=0
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
WHITE='\033[0;37m'
NC='\033[0m'
section "Tener instalado antes UFW" $RED
echo -e "${WHITE}Elige opción"
echo "1- Instalacion Prometheus + Grafana"
echo "2- Instalación Node_Exporter"
echo "3- Configuracion Prometheus Node_Exporter"
echo "4- Configuracion Prometheus SMNP_Exporter"
echo "Inserta opción:  "
read option
if [ $option  == '1' ]; then
    section "Descargando Prometheus.." $GREEN
    if wget  "https://github.com/prometheus/prometheus/releases/download/v3.4.0/prometheus-3.4.0.linux-amd64.tar.gz"
    #if true
    then
        PATH_WORK=$(pwd)
        section "Prometheus Descargado!" $GREEN
        section "Descomprimiendo..." $WHITE
        tar -xvzf prometheus-3.4.0.linux-amd64.tar.gz
        section "Descompresión completada" $GREEN
        section "Instalando binarios Prometheus..." $WHITE
        sudo mv prometheus-3.4.0.linux-amd64/prometheus /usr/local/bin/
        sudo mv prometheus-3.4.0.linux-amd64/promtool /usr/local/bin/
        section "Instalación completada Binarios movidos a /usr/local/bin" $GREEN
        section "Iniciando Creación Servicio Prometheus..." $GREEN
        cd /etc/systemd/system/
	    sudo touch prometheus.service
        echo "[Unit]
Description=Prometheus
After=network.target
[Service]
User=root
Group=root
Type=simple
ExecStart=/usr/local/bin/prometheus --config.file=$PATH_WORK/prometheus-3.4.0.linux-amd64/prometheus.yml  --storage.tsdb.path=$HOME/prometheus-data
Restart=always
[Install]
WantedBy=multi-user.target" | sudo tee prometheus.service
        sudo systemctl daemon-reload
        sudo systemctl start prometheus
        sudo systemctl enable prometheus
        section "Servicio Prometheus creado..." $GREEN
        sudo systemctl --no-pager status prometheus
        section "Prometheus listo..." $GREEN

        section "Instalación Grafana" $WHITE
        if command -v sqlite3 >/dev/null 2>&1; then
            section "sqlite3 OK!" $GREEN
        else
            section "sqlite3 no está instalado" $RED
            section "Instalando sqlite3..." $WHITE
            sudo apt install sqlite3
            section "sqlite3 instalado" $GREEN
            section "Continuando con grafana..." $WHITE
        fi
        cd $PATH_WORK
        sudo apt-get install -y adduser libfontconfig1 musl
        if wget https://dl.grafana.com/enterprise/release/grafana-enterprise-12.0.0+security-01.linux-amd64.tar.gz
        
        #if true
        then 
            section "Descarga Grafana completada" $GREEN
            section "Descomprimiendo Grafana..." $WHITE
            tar -zxvf grafana-enterprise-12.0.0+security-01.linux-amd64.tar.gz
            section "Descompresión Grafana completada" $GREEN
            section "Creando usuario Grafana..." $WHITE
            sudo useradd -r -s /bin/false grafana
            section "Moviendo Binarios a /usr/local/grafana" $WHITE
            sudo mv  grafana-v12.0.0+security-01 /usr/local/grafana
            
            section "Cambie el propietario de /usr/local/grafana a usuarios de Grafana" $WHITE
            sudo chown -R grafana:users /usr/local/grafana
            section "Instalación Grafana completada" $GREEN
            section "Creando servicio Grafana..." $WHITE
            sudo touch /etc/systemd/system/grafana-server.service
            echo "[Unit]
Description=Grafana Server
After=network.target

[Service]
Type=simple
User=grafana
Group=users
ExecStart=/usr/local/grafana/bin/grafana server --config=/usr/local/grafana/conf/grafana.ini --homepath=/usr/local/grafana
Restart=on-failure

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/grafana-server.service
            # necesitamos mover las configuraciones por default de grafana a la carpeta de configuracion
            sudo cp /usr/local/grafana/conf/defaults.ini /usr/local/grafana/conf/grafana.ini
            section "Servicio Grafana creado" $GREEN
            section "Recargando demonios..." $WHITE
            sudo systemctl daemon-reload
            section "Iniciando Grafana..." $WHITE
            sudo systemctl start grafana-server
            section "Habilitando Grafana..." $WHITE
            sudo systemctl enable grafana-server
            section "Grafana iniciado y habilitado" $GREEN
            section "Estado de Grafana" $WHITE
            sudo systemctl --no-pager status grafana-server
            section "Grafana listo..." $GREEN

        else
            section "Error al descargar Grafana" $RED
        fi

    else
        section "Error al descargar Prometheus" $RED
    fi
elif [ $option == 2 ]; then
    section "Instalando Node_Exporter" $WHITE
    if wget "https://github.com/prometheus/node_exporter/releases/download/v1.9.1/node_exporter-1.9.1.linux-amd64.tar.gz"
    then 
        section "Descarga Node_Exporter completada" $GREEN
        section "Descomprimiendo Node_Exporter..." $WHITE
        tar -zxvf node_exporter-1.9.1.linux-amd64.tar.gz
        section "Descompresión Node_Exporter completada" $GREEN
        section "Moviendo binarios a /usr/local/bin" $WHITE
        sudo mv node_exporter-1.9.1.linux-amd64/node_exporter /usr/local/bin/
        section "Creando servicio Node_Exporter..." $WHITE
        sudo touch /etc/systemd/system/node_exporter.service
        echo "[Unit]
Description=Node Exporter
After=network.target
[Service]
User=root
ExecStart=/usr/local/bin/node_exporter
[Install]
WantedBy=multi-user.target" | sudo tee "/etc/systemd/system/node_exporter.service"
        section "Servicio Node_Exporter creado" $GREEN
        section "Recargando demonios..." $WHITE
        sudo systemctl daemon-reload
        section "Iniciando Node_Exporter..." $WHITE
        sudo systemctl start node_exporter
        section "Habilitando Node_Exporter..." $WHITE
        sudo systemctl enable node_exporter
        section "Node_Exporter iniciado y habilitado" $GREEN
        section "Estado de Node_Exporter" $WHITE
        sudo systemctl --no-pager status node_exporter
        section "Node_Exporter listo..." $GREEN
        sudo ufw allow 9100
        sudo ufw status


    else 
        section "Error al descargar Node_Exporter" $RED
    fi
fi


