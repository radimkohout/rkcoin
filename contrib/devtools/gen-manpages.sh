#!/bin/bash

TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
SRCDIR=${SRCDIR:-$TOPDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

FUNCOIND=${FUNCOIND:-$SRCDIR/rkcoind}
FUNCOINCLI=${FUNCOINCLI:-$SRCDIR/rkcoin-cli}
FUNCOINTX=${FUNCOINTX:-$SRCDIR/rkcoin-tx}
FUNCOINQT=${FUNCOINQT:-$SRCDIR/qt/rkcoin-qt}

[ ! -x $FUNCOIND ] && echo "$FUNCOIND not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
RKCVER=($($FUNCOINCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for bitcoind if --version-string is not set,
# but has different outcomes for bitcoin-qt and bitcoin-cli.
echo "[COPYRIGHT]" > footer.h2m
$FUNCOIND --version | sed -n '1!p' >> footer.h2m

for cmd in $FUNCOIND $FUNCOINCLI $FUNCOINTX $FUNCOINQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${RKCVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${RKCVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m
