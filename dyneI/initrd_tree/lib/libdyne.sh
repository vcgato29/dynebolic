#!/bin/sh
#
# miscellaneous procedures called by dyne:bolic initialization scripts
#
#  * Copyright (C) 2003 Denis Rojo aka jaromil <jaromil@dyne.org>
#  * and Alex Gnoli aka smilzo <smilzo@sfrajone.org>
#  * freely distributed in dyne:bolic GNU/Linux http://dynebolic.org
#  * 
#  * This source code is free software; you can redistribute it and/or
#  * modify it under the terms of the GNU Public License as published 
#  * by the Free Software Foundation; either version 2 of the License,
#  * or (at your option) any later version.
#  *
#  * This source code is distributed in the hope that it will be useful,
#  * but WITHOUT ANY WARRANTY; without even the implied warranty of
#  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#  * Please refer to the GNU Public License for more details.
#  *
#  * You should have received a copy of the GNU Public License along with
#  * this source code; if not, write to:
#  * Free Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#  *
#  * "Header: $"


# by jaromil & smilzo - 6 july 2003

DYNEBOL_NST="dynebol.nst"
DYNEBOL_CFG="dynebol.cfg"

dyne_mount_nest() {
  # $1 = full path to dyne:bolic nest configuration (dynebol.cfg)
  # returns 1 on failure, 0 on success
  if [ ! -e $1 ]; then return fi
  if [ -e /boot/nest ]; then
    echo "[!] another nest found on $1"
    echo " .  it overlaps an allready mounted nest, skipped!"
  fi
  echo "[*] activating dyne:bolic nest in $1"
  source $1
  # TODO : controllare che il file di conf abbia tutto apposto
  if [ -z $DYNEBOL_ENCRYPT ]; then
    clear
    cat <<EOF




*******************************************************************************
An $DYNEBOL_ENCRYPT encrypted nest
has been detected in $DYNEBOL_NST
access is password restricted, please supply your passphrase now

EOF
    mount -o loop,encryption=$DYNEBOL_ENCRYPT $DYNEBOL_NST /mnt/nest
    if [ $? != 0 ]; then
      echo
      echo "Invalid password or corrupted file"
    fi
  else
    mount -o loop $DYNEBOL_NST /mnt/nest
  fi
  
  if [ $? != 0 ]; then 
    echo "[!] can't mount nest, skipping"
    # ce ne andiamo senza togliere le variabili di ambiente
    # il che le rende inaffidabili per detctare la presenza di un nido montato
    # USARE /boot/nest per quello!
    return 1
  fi
  
  echo " .  nest succesfully mounted"

  # ok, success! we mount the nest


  if [ -e /mnt/nest/etc ]; then
    cp /etc/fstab /tmp
    cp /etc/auto.removable /tmp
    # qui c'e' un problema concettuale dice lo smilzo :)
    # in effetti si monta bindata una etc sopra l'altra
    # ma il mount in questo modo non puo' aggiornare correttamente mtab
    # siamo in cerca di soluzioni
    # quantomeno allo shutdown si dovranno smontare a mano le dir del nest
    mount -o bind /mnt/nest/etc /etc
    mv /tmp/fstab /etc
    mv /tmp/auto.removable /tmp
    echo " .  nested /etc directory bind"
  else
    echo "[!] nest is missing /etc directory"
  fi 

  if [ -e /mnt/nest/home ]; then
    mount -o bind /mnt/nest/home /home
    echo " .  nested /home directory bind"
  else
    echo "[!] nest is missing /home directory"
  fi

  echo "$1" > /boot/nest
  echo " .  nest activated"
  return 0
}

dyne_gen_wmaker_dock() {
  # $1 = media type (hdisk|floppy|usbkey)
  # $2 = mount point
  echo "[*] generating wmaker dock icon for $1 on $2"
}

