#!/bin/sh
exec vlc "mms://livemedia.omroep.nl/vprohollanddoc-bb" --sout "#transcode{vcodec=mp2v,acodec=mpga,vb=2400,ab=320}:standard{access=udp,mux=ts{pid-video=1,pid-audio=2,pid-spu=3},dst=127.0.0.1:4321}" --intf dummy

