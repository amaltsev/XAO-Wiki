#include "EXTERN.h"
#include "perl.h"  
#include "XSUB.h"  

#include "wparser/wparser.h"
#include "wparser/s_string.h"

MODULE = XAO::WikiParser   PACKAGE = XAO::WikiParser

SV *
parse(char *s)
    CODE:
        AV * results;
        HV * rh;
        const char *blockname;
        string str;
        str=s;
        int i,n;
        struct gtreftable reftable;
        memset(&reftable,0,sizeof(struct gtreftable));
        results = (AV *)sv_2mortal((SV *)newAV());
        n=parse_to_blocks(str,&reftable);
        for(i=0;i<n;i++)
         {
            if(reftable.reflist[i].skip) continue;
            rh = (HV*)sv_2mortal((SV*)newHV());
            blockname=blocktype2name(reftable.reflist[i].type);
            hv_store(rh, "type", 4, newSVpvn(blockname, strlen(blockname)), 0);
            if(reftable.reflist[i].level)
              hv_store(rh, "level", 5, newSVnv(reftable.reflist[i].level),0);
            if(reftable.reflist[i].opcode)
              hv_store(rh, "opcode", 6, newSVpvn(reftable.reflist[i].opcode,
                              strlen(reftable.reflist[i].opcode)),0);
            hv_store(rh, "content", 7, newSVpvn(reftable.reflist[i].text,
                                strlen(reftable.reflist[i].text)), 0);
            av_push(results, newRV((SV *)rh));
         }
        free_reftable(&reftable);
        RETVAL = newRV((SV *)results);
    OUTPUT:
        RETVAL
