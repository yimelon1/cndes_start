vcs -full64  -R -kdb 	\
-debug_access+all	\
-override_timescale=1ns/100ps	\
-sverilog +v2k		\
+notimingcheck		\
-l sim_log/ssm.log	\
+incdir+../		\
-y ../			\
+libext+.sv+.v 	\
-f vcode.f \
+define+RTL		\
-P ${VERDI_HOME}/share/PLI/VCS/LINUX64/novas.tab	\
${VERDI_HOME}/share/PLI/VCS/LINUX64/pli.a
