jubatus:
	export JUBATUS_HOME="/opt/jubatus"
	export PATH="${JUBATUS_HOME}/bin:${PATH}"
	export LD_LIBRARY_PATH="${JUBATUS_HOME}/lib:${LD_LIBRARY_PATH}"
	export LDFLAGS="-L${JUBATUS_HOME}/lib ${LDFLAGS}"
	export CPLUS_INCLUDE_PATH="${JUBATUS_HOME}/include:${CPLUS_INCLUDE_PATH}"
	export PKG_CONFIG_PATH="${JUBATUS_HOME}/lib/pkgconfig:${PKG_CONFIG_PATH}"
	nohup /opt/jubatus/bin/jubanearest_neighbor -d . -f settings.json -p 9200

clean:
	echo "cleaning start"
	rm ./*.jubatus
	python ./format.py
	echo "please stop/reboot jubatus"
