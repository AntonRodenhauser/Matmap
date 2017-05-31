/* FILE: mexReadTSDFC.c  
   AUTHOR: Jeroen Stinstra
   CONTENTS: Wrting fiducials to a tsdfc file 
   
   LASTUPDATE: 7 JUN 2002.
 *
 */
 
 /* 
   This function writes fiducials in a TSDFC file. 
 */
 
/* Do the standard includes */

#include <stdio.h>
#include <math.h>
#include <mex.h>
#include "gdbm.h"

/* include a bunch of functions */

#include "myfile.c"
#include "myerror.c"
#include "misctools.c"

/* just define them */
#define FALSE	0
#define TRUE	1

typedef struct 		  { double 	*fids;
                            long	size;
			    long 	type;
			    long 	fidset;    
                            long	fidsetnum;     /* new fidset number */
                        } my_fids;

typedef struct            { char 	*label;
			    char 	*audit;
		          } my_fidset;	

typedef struct               {  short   type;
                                short	version;
                                int	size;
                                char	*audit;
                                int	auditsize;
                                char	*label;
                                int	labelsize;
				int     stdlabel,stdaudit;
                                int	fidsdescarraysize; 
                                short	*fidsdescarray;
                                int	fidsvaluesarraysize;
                                float	*fidsvaluesarray;
                                short	*fidstypesarray;
                              } fidset;
                              

/* Function definitions */
my_fids		*GetFidsArray(mxArray *fidsarray);
my_fidset 	*GetFidsetArray(mxArray *fidsetarray);
datum 		EncodeFidset(mxArray *fidsarray, mxArray *fidsetarray);
int 		WriteFidset(char *tsdfcfilename,char *tsdffilename, datum data);

/* globals */

char 	matlablabelglobal[]  = "Matlab generated global fiducials";
char 	matlablabellocal[]  = "Matlab generated local fiducials";
char	matlabaudit[]  = "Fiducials generated by mexWriteTSDFC()";
                            
                            
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
/* Entry point for MATLAB. 
    lefthandside                        righthandside
    [outmat1,outmat2,...] = function(inmat1,inmat2,...)
    nlhs - number of parameters on leftside hand of expression
    plhs - a pointer to an array of pointers representing the various arrays on this side
    nrhs - idem right hand side
    prhs - idem array pointer right hand side
*/
{
    char		*tsdffilename, *tsdfcfilename;
    mxArray		*fidsarray, *fidsetarray;
    datum		datum,emptydatum;
    short               emptydata[4] = {0,0,0,0};    
    int			success;   

    /*  Set usage string 
	The function input is: 
	    - TSDFC char matrix containing the filename
	    - TSDF char matrix containing the key 
	The output are two sets of arrays
	    - a fids array this one contains a fid entry and contains parts of the 
	      fidsets broken down in parts so in each entry there is one type of
	      fiducial and which can be a vector or scalar depending on the local or global 
	      status of the fiducial.
	    - fidset cell array, representing all fidsets in the timeseries, it contains all
	      the data like the auditstring, the label, but not the data as it is broken down
	      in smaller pieces in fids. fids does contain a pointer to fidset in the form of
	      an index.       
     */
    /* SET UP USAGE */

    errUsage("mexWriteTSDFC(TSDFC-filename,TSDF-filename/key,fids,fidset)"); /* no error, just setting usage once and for all */
    success = 0;

    /* INITIALISE  POINTERS */
    
    tsdfcfilename  = NULL;
    tsdffilename   = NULL;
    datum.dptr	   = NULL;
    
    while(1)
    {
    
        if (nrhs == 2)
        {
	
            if (!mxIsChar(prhs[0])) 	{ errError("mexFunction","TSDFC-filename needs to be a string"); break; }
            if (!mxIsChar(prhs[1])) 	{ errError("mexFunction","TSDF-filename needs to be a string"); break; }
            if (nlhs > 0)				{ errError("mexFunction","No output is generated by this function"); break; }
	
            /* Retrieve the filenames */
    
            if (!( tsdfcfilename = miscConvertString((mxArray *)prhs[0]))) { errError("mexFunction","Could not allocate memory for (tsdfc filename)"); break; }
            if (!( tsdffilename = miscConvertString((mxArray *)prhs[1])))  { errError("mexFunction","Could not allocate memory for (tsdf filename)"); break; }

            /* Fill up the fiducial set with an empty header filled with zeros, so there is a link but no data */
            emptydatum.dptr = (char *) emptydata;
            emptydatum.dsize = 4*sizeof(short);
        
            if(!( WriteFidset(tsdfcfilename,tsdffilename,emptydatum))) { errError("mexFunction","Could not write fiducials into the tsdfc-file"); break; }
            success = 1;
            break;
        }


        if (nrhs == 4)
        {
	
            if (!mxIsChar(prhs[0])) 	{ errError("mexFunction","TSDFC-filename needs to be a string"); break; }
            if (!mxIsChar(prhs[1]))	{ errError("mexFunction","TSDF-filename needs to be a string"); break; }
            if (!mxIsStruct(prhs[2]))	{ errError("mexFunction","fids needs to be a structured array"); break; }
            if (!mxIsCell(prhs[3]))	{ errError("mexFunction","fidset needs to be a cell array"); break; }
            if (nlhs > 0)		{ errError("mexFunction","No output is generated by this function"); break; }
        	
            /* Retrieve the filenames */
    
            if(!(tsdfcfilename = miscConvertString((mxArray *)prhs[0])))  { errError("mexFunction","Could not allocate memory for (tsdfc filename)"); break; }
            if(!(tsdffilename = miscConvertString((mxArray *)prhs[1])))   { errError("mexFunction","Could not allocate memory for (tsdf filename)"); break; }

            fidsarray = (mxArray *)prhs[2];
            fidsetarray = (mxArray *)prhs[3];
    
            /* So the filenames are read */	
  
            datum = EncodeFidset(fidsarray,fidsetarray);
            if (datum.dptr == NULL) { errError("mexFunction","Could not Encode the fidset and fids array into the tsdfc-containter format"); break; }
            if(!(WriteFidset(tsdfcfilename,tsdffilename,datum))) { errError("mexFunction","Could not write the fidset into the tsdfc-file"); break; }
            
            success = 1;
            break;
        }
    
        if (!success)  { errError("mexFunction","The name of the TSDFC-file and the TSDF-file are needed and the fiducials and the fidsets"); break; }
    }

    if (datum.dptr) mxFree(datum.dptr);
    if (tsdffilename) mxFree(tsdffilename);
    if (tsdfcfilename) mxFree(tsdfcfilename);
    
    if (!success)
    {
        mexErrMsgTxt("ERROR: mexWriteTSDFC could not write the fiducials\n");
        return;
    }

    return;
}

my_fids	*GetFidsArray(mxArray *fidsarray)
/* This function translates the matlab array in a normal array 
   and stores the fiducials in a large array */
{
    int		typeindex,valueindex,fidsetindex;
    long	p; /* loop counters */
    long	numfidsarray;   /* how long is fids array */
    my_fids	*myfids;
    mxArray	*array;		/* to store a subarray in */
    double	*data;		/* to store the contents of a matrix */
    int		success, loopsuccess;
    
    success = 0;
    
    myfids = NULL;
    
    while(1)
    {
        if(!(mxIsStruct(fidsarray))) { errError("GetFidsArray","fidsarray is not a struct"); break; }
        
        numfidsarray = (long)(mxGetN(fidsarray)*mxGetM(fidsarray));
        if (!( myfids = (my_fids *)mxCalloc(numfidsarray,sizeof(my_fids)))) { errError("GetFidsArray","Cannot allocate memory"); break; }

        /* process fidsarray */
    
        valueindex = mxGetFieldNumber(fidsarray,"value");
        if( valueindex < 0 ) { errError("GetFidsArray","The value field is lacking from the fidsarray"); break; }
        
        typeindex = mxGetFieldNumber(fidsarray,"type");
        if( typeindex < 0 ) { errError("GetFidsArray","The type field is lacking from the fidsarray"); break; }
        
        fidsetindex = mxGetFieldNumber(fidsarray,"fidset");
        if( fidsetindex < 0 ) { errError("GetFidsArray","The fidset field is lacking from the fidsarray"); break; }
        

        /* Build an array composed with the contents of the fidsarray for easier access */

        loopsuccess = 0;
        for(p=0;p<numfidsarray;p++)
        {
            array = mxGetFieldByNumber(fidsarray,p,valueindex);
            myfids[p].fids = mxGetPr(array);
            myfids[p].size = (long)(mxGetN(array)*mxGetM(array));
        
            array = mxGetFieldByNumber(fidsarray,p,typeindex);
            /* if(!( data = mxGetPr(array))) { errError("GetFidsArray","Could not access type in fids array"); break; } */
            
            if(!( data = mxGetPr(array))) myfids[p].type = 0; else myfids[p].type = (long) data[0];
        
            array = mxGetFieldByNumber(fidsarray,p,fidsetindex);
            /* if(!( data = mxGetPr(array))) { errError("GetFidsArray","Could not access fidset in fids array"); break; } */
            
            if(!( data = mxGetPr(array))) myfids[p].fidset = 0; else myfids[p].fidset = (long) data[0];
            myfids[p].fidsetnum = 0;
            
            if (p==numfidsarray-1) {loopsuccess = 1; break; }
        }
    
        if (!loopsuccess) break;
        
        success = 1;
        break;
    }
    
    /* CLEAN UP AND RETURN RESULTS */
    
    if (!success)
    {
        if (myfids) mxFree(myfids);
        return(NULL);
    }
    else
    {
        return(myfids);
    }
}


my_fidset	*GetFidsetArray(mxArray *fidsetarray)
/* This function translates the matlab array in a normal array 
   and stores the fidset data in a large array */
{
    mxArray	*label,*audit,*structarray;
    long	p; /* loop counters */
    long	numfidsetarray; /* kow long is fids array */
    my_fidset	*myfidset;
    int		success, loopsuccess;
    
    success 	= 0;
    myfidset 	= NULL;

    while(1)
    {
        if(!(mxIsCell(fidsetarray))) { errError("GetFidsetArray","fidsetarray is not a cellarray"); break; }

        numfidsetarray = (long)(mxGetN(fidsetarray)*mxGetM(fidsetarray));

	if (numfidsetarray == 0)
	{
		  return(NULL);
	}

        if (!( myfidset = (my_fidset *)mxCalloc(numfidsetarray,sizeof(my_fidset))))  { errError("GetFidsetArray","Cannot allocate memory"); break; }

        /* Build an array composed with the contents of the fidsarray for easier access */

        loopsuccess = 0;
        for(p=0;p<numfidsetarray;p++)
        {
            myfidset[p].label = NULL;
            myfidset[p].audit = NULL;
    
            if (!( structarray = mxGetCell(fidsetarray,p))) continue;		/* go to next cell */
            if ( label = mxGetField(structarray,0,"label"))
                if(!(myfidset[p].label = miscConvertString(label))) { errError("GetFidsetArray","Could not convert label string"); break; }
            if ( audit = mxGetField(structarray,0,"audit"))
                if(!(myfidset[p].audit = miscConvertString(audit))) { errError("GetFidsetArray","Could not convert audit string"); break; }
            if (p == numfidsetarray-1) loopsuccess = 1;
        }
        
        if (!loopsuccess) break;
        
        success = 1;
        break;
    }
    
    if (!success)
    {
        if(myfidset)
        {
            for (p=0;p<numfidsetarray;p++)
            {
                if (myfidset[p].label) mxFree(myfidset[p].label);
                if (myfidset[p].audit) mxFree(myfidset[p].audit);
            }
            mxFree(myfidset);
        }
	return(NULL);
    }
    else
    {
        return(myfidset);
    }
}


datum EncodeFidset(mxArray *fidsarray, mxArray *fidsetarray)
/* Encode the data again to fit in the tsdfc files again */
{
    long 	numfidsetarray,numfidsarray;
    my_fids	*myfids;
    my_fidset	*myfidset;
    fidset	*newfidset;
    long	p,q,r,s,size,numfidset,fidsetsize,fidsetnumber;
    int		blocksize,datasize,headersize;
    datum	data;
    char	*cdata;
    int		success,loopsuccess;
 
    /* INITIALISE THE DEFAULT */

    data.dptr = NULL;
    data.dsize = 0;
 
    success 	= 0;
    myfids  	= NULL;
    myfidset	= NULL;
    newfidset	= NULL;
    numfidset 	= 0;
    
    while(1)
    {
        numfidsarray =   (long)(mxGetN(fidsarray)*mxGetM(fidsarray));
        numfidsetarray = (long)(mxGetN(fidsetarray)*mxGetM(fidsetarray));

        if(!(myfids = GetFidsArray(fidsarray))) { errError("EncodeFidset","Could not preprocess the fids array"); break; }
		/* if(!(myfidset = GetFidsetArray(fidsetarray))) { errError("EncodeFidset","Could not preprocess the fids array"); break; } */

		myfidset = GetFidsetArray(fidsetarray); 
        numfidset = 0;
    
        /* The basic idea is to sort out which fiducials can be combined into
           one fiducial set, the criterium is : size should be equal and fidset.
           If so mark them in fidsetnum and give all the same number. This number
           will be used lateron to decide which fiducials are put in the same fidset */
    

        for (p=0;p<numfidsarray;p++)
        {
            if (myfids[p].fidsetnum == 0)
            {
                myfids[p].fidsetnum = ++numfidset;  /* we found a new fidset */
                fidsetnumber = myfids[p].fidset;
                size = myfids[p].size;
                  
                for (q=p+1;q<numfidsarray;q++)
                {
                    if ((myfids[q].size == size)&&(myfids[q].fidset == fidsetnumber)) 
                    {
                        myfids[q].fidsetnum = numfidset;
                    }
                }
            }
        }

    
        if(!( newfidset = (fidset *)mxCalloc(numfidset,sizeof(fidset)))) { errError("EncodeFidset","Could not allocate memory for new set"); break; }
   
        blocksize = 0;    
         
        loopsuccess = 0;
        
        for (p=0;p<numfidset;p++)
        {
            fidsetsize = 0;
            size = 0;
            fidsetnumber = 0;
            datasize = 0;
            headersize = sizeof(short)+sizeof(short)+sizeof(int);	/* tsdfc-subheader */
        
            newfidset[p].type = 1;
            newfidset[p].version = 0;
            newfidset[p].label = NULL;
            newfidset[p].audit = NULL;
           
            /* determine the size of this fidset, the number of fiucials and the length of the fiducials */
            for (q=0;q<numfidsarray;q++) 
                if (myfids[q].fidsetnum == p+1) { fidsetsize++; size = myfids[q].size; fidsetnumber = myfids[q].fidset;}
            
            if ((fidsetnumber > 0)&&(fidsetnumber < numfidsetarray+1)&&(myfidset != NULL))
            {
                newfidset[p].label = myfidset[fidsetnumber-1].label; myfidset[fidsetnumber-1].label = NULL;
                newfidset[p].audit = myfidset[fidsetnumber-1].audit; myfidset[fidsetnumber-1].audit = NULL;
            }

            if (newfidset[p].label == NULL) 
            {
                if (size > 1) 
                    { newfidset[p].label = matlablabellocal; }
                else 
                    { newfidset[p].label = matlablabelglobal; }
				newfidset[p].stdlabel = 1;
            }
            
            if (newfidset[p].audit == NULL) { newfidset[p].audit = matlabaudit; newfidset[p].stdaudit = 1; }

            newfidset[p].labelsize = strlen(newfidset[p].label);
            newfidset[p].auditsize = strlen(newfidset[p].audit);
            datasize += sizeof(int) + newfidset[p].labelsize;
            datasize += sizeof(int) + newfidset[p].auditsize;

            newfidset[p].fidsdescarraysize = (int) size;           
            if (!( newfidset[p].fidsdescarray = (short *)mxCalloc(size,sizeof(short))))	{ errError("EncodeFids","Could not allocate memory (descarray)"); break; }
            
            for (q=0;q<size;q++) newfidset[p].fidsdescarray[q] = (short) fidsetsize;        
        
            datasize += sizeof(int) + size*sizeof(short);
            newfidset[p].fidsvaluesarraysize = (long) size*fidsetsize;
        
            if (!( newfidset[p].fidsvaluesarray = (float *)mxCalloc(size*fidsetsize,sizeof(float)))) { errError("EncodeFids","Could not allocate memory (valuesarray)"); break; }
            if (!( newfidset[p].fidstypesarray = (short *)mxCalloc(size*fidsetsize,sizeof(short)))) { errError("EncodeFids","Could not allocate memory (typesarray)"); break; }
        
            datasize += sizeof(int) + sizeof(float)*(size*fidsetsize) + sizeof(short)*(size*fidsetsize);
        
            newfidset[p].size = datasize;
        
            r = 0; /* counter on the fiducials */
            /* fill out the last two matrices */
            for (q=0;q<numfidsarray;q++) 
            {
                if (myfids[q].fidsetnum == p+1)
                {
                    for (s=0;s<size;s++) 
                    { 
                        newfidset[p].fidstypesarray[s*fidsetsize+r] = myfids[q].type;
                        newfidset[p].fidsvaluesarray[s*fidsetsize+r] = (float) myfids[q].fids[s];    
                    }
                    r++;
                }
            }
            blocksize += headersize+datasize;
            if (p == numfidset-1) { loopsuccess = 1; break; }
        }    

	if (!loopsuccess) break;
        
        /***************************************************
            Next step is to pu everything in a datum array
        ******************************************************/
    
        /* allocate memory block */
        
        if (blocksize == NULL) { errError("EncodeFidset","Error encoding the data set everything seems to be empty"); break; }
        
        if(!(data.dptr = (char *) mxCalloc(blocksize,sizeof(char)))) { errError("EncodeFids","Could not allocate memory to store the fidset data (datum block)"); break; }
        data.dsize = blocksize;
    
    
        cdata = data.dptr;
        /* fill out structure */

        for (p=0;p<numfidset;p++)
        { 
            cdata = (char *) mfmemwrite((void *)&(newfidset[p].type),sizeof(short),1,(void *)cdata,mfSHORT);
            cdata = (char *) mfmemwrite((void *)&(newfidset[p].version),sizeof(short),1,(void *)cdata,mfSHORT);
            cdata = (char *) mfmemwrite((void *)&(newfidset[p].size),sizeof(int),1,(void *)cdata,mfINT);
        
            cdata = (char *) mfmemwrite((void *)&(newfidset[p].labelsize),sizeof(int),1,(void *)cdata,mfINT);
            cdata = (char *) mfmemwrite((void *)newfidset[p].label,sizeof(char),newfidset[p].labelsize,(void *)cdata,mfCHAR);
        
            cdata = (char *) mfmemwrite((void *)&(newfidset[p].auditsize),sizeof(int),1,(void *)cdata,mfINT);
            cdata = (char *) mfmemwrite((void *)newfidset[p].audit,sizeof(char),newfidset[p].auditsize,(void *)cdata,mfCHAR);
        
            cdata = (char *) mfmemwrite((void *)&(newfidset[p].fidsdescarraysize),sizeof(int),1,(void *)cdata,mfINT);
            cdata = (char *) mfmemwrite((void *)newfidset[p].fidsdescarray,sizeof(short),newfidset[p].fidsdescarraysize,(void *)cdata,mfSHORT);
        
            cdata = (char *) mfmemwrite((void *)&(newfidset[p].fidsvaluesarraysize),sizeof(int),1,(void *)cdata,mfINT);
            cdata = (char *) mfmemwrite((void *)newfidset[p].fidsvaluesarray,sizeof(float),newfidset[p].fidsvaluesarraysize,(void *)cdata,mfFLOAT);
            cdata = (char *) mfmemwrite((void *)newfidset[p].fidstypesarray,sizeof(short),newfidset[p].fidsvaluesarraysize,(void *)cdata,mfSHORT);

        }
        

        success = 1;
        break;
    }
    
    /* CLEAN UP */
    

    if (newfidset)
    {
        for (p=0;p<numfidset;p++)
        {
            if(newfidset[p].fidsdescarray) mxFree(newfidset[p].fidsdescarray);
            if(newfidset[p].fidsvaluesarray) mxFree(newfidset[p].fidsvaluesarray);
            if(newfidset[p].fidstypesarray) mxFree(newfidset[p].fidstypesarray);
            if(newfidset[p].stdlabel == 0) if(newfidset[p].label) mxFree(newfidset[p].label);
            if(newfidset[p].stdaudit == 0) if(newfidset[p].audit) mxFree(newfidset[p].audit);
        }
        mxFree(newfidset);
    }

    
    if(myfidset)
    {
        for (p=0;p<numfidsetarray;p++)
        {
            if (myfidset[p].label) mxFree(myfidset[p].label);
            if (myfidset[p].audit) mxFree(myfidset[p].audit);
        }
        mxFree(myfidset);
    }
    if (myfids) mxFree(myfids);


    if (!success)
    {
        if (data.dptr) mxFree(data.dptr);
        data.dptr = NULL;
    }
  


    return(data);
}


int WriteFidset(char *tsdfcfilename,char *tsdffilename, datum data)
/* This function generates new fidset fot the tsdfc file */
{
    GDBM_FILE 	file;
    datum	key;
    int 	success;
    
    if (data.dptr == NULL) return(0);		/* Apparently there is no data (should be dealt with earlier but just in case) */
    
    success = 0;
    file = NULL;

    while(1)
    {
        if (!(file = gdbm_open(tsdfcfilename,1024,GDBM_WRCREAT|GDBM_NOLOCK,00644,NULL)))   { errError("WriteFidset","Could not open file"); break; }
        key.dptr = (char *)tsdffilename;
        key.dsize = strlen(tsdffilename);
        if ( gdbm_store(file,key,data,GDBM_REPLACE)) { errError("WriteFidset","Could not store the fiducials in the TSDFC-file"); break; }
        gdbm_reorganize(file);
        success = 1;
        break;
    }

    if (file) gdbm_close(file);    
    if (!success) return(0);
    
    return(1);
}

