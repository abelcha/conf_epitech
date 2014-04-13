grep -rh \)$ | grep ^[icvt] | grep -v main > prototypes.h; sed -i 's/\t\t/\t/g' prototypes.h;
    sed -i 's/\t\t/\t/g' prototypes.h; sed -i 's/$/\;/g' prototypes.h;


sed -i '1i\#ifndef PROTOTYPES_H_' prototypes.h;
sed -i "1i\# define PROTOTYPES_H_" prototypes.h;

echo "
#endif /* !PROTOTYPES_H_"  >> prototypes.h


cat prototypes.h;
