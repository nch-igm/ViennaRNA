/**********************************************/
/* BEGIN interface for fold compound          */
/**********************************************/

/* ignore all data structures we handle elsewhere */
%ignore PAIR;
%ignore plist;
%ignore cpair;
%ignore sect;
%ignore bondT;
%ignore pu_contrib;
%ignore interact;
%ignore pu_out;
%ignore constrain;
//%ignore duplexT;
%ignore folden;
%ignore snoopT;
%ignore dupVar;

/* add callback binding methods for fold_compound */
%include callbacks-fc.i
%include callbacks-sc.i


/* start constructing a sane interface to vrna_fold_compound_t */

%rename(fc_type) vrna_fc_type_e;

/* scripting language access through 'fold_compound' instead of 'vrna_fold_compound_t' */
%rename(fold_compound) vrna_fold_compound_t;

/* no default constructor / destructor */
%nodefaultctor vrna_fold_compound_t;
%nodefaultdtor vrna_fold_compound_t;


/* hide all attributes in vrna_fold_compound_t */
typedef struct {} vrna_fold_compound_t;


/* scripting language takes ownership of objects returned by mfe() method */
%newobject vrna_fold_compound_t::mfe;
%newobject vrna_fold_compound_t::pt_test;
%newobject vrna_fold_compound_t::eval_covar_structure;
%newobject vrna_fold_compound_t::centroid;
%newobject vrna_fold_compound_t::eval_structure_pt;

/* create object oriented interface for vrna_fold_compount_t */
%extend vrna_fold_compound_t {

	  
  /* the default constructor, *md and option are optional, for single sequences*/
  vrna_fold_compound_t(const char *sequence, vrna_md_t *md=NULL, unsigned int options=VRNA_OPTION_MFE){
    return vrna_fold_compound(sequence, md, options);
  }
   /*the constructor for alignments, *md and options are optional  */
   vrna_fold_compound_t(std::vector<string> alignment, vrna_md_t *md=NULL, unsigned int options=VRNA_OPTION_MFE)
   {
	   std::vector<const char*>  vc;
	   transform(alignment.begin(), alignment.end(), back_inserter(vc), convert_vecstring2veccharcp);
	   vc.push_back(NULL); /* mark end of sequences */
	   return vrna_fold_compound_comparative((const char **)&vc[0], md, options);
  }
  /* constructor for distance class partitioning, *md and options are, for single sequences*/
  vrna_fold_compound_t(const char *sequence,char *s1,char *s2, vrna_md_t *md=NULL, unsigned int options=VRNA_OPTION_MFE)
  {
    return vrna_fold_compound_TwoD(sequence,s1,s2, md, options);
  }
  
  
  
  ~vrna_fold_compound_t(){
    vrna_fold_compound_free($self);
  }
  

  vrna_fc_type_e type(){
    return $self->type;
  }
  
  unsigned int length()
  {
	  return $self->length;
  }

  
  /*##############
   * from MFE.h
	###########*/
  
  char *mfe(float *OUTPUT){
    char *structure = (char *)vrna_alloc(sizeof(char) * ($self->length + 1));
    *OUTPUT = vrna_mfe($self, structure);
    return structure;
  }
  /*MFE for 2 RNA strands*/
  char *mfe_dimer(float *OUTPUT){
    char *structure = (char*)vrna_alloc(sizeof(char) * ($self->length + 1));
    *OUTPUT = vrna_mfe_dimer($self, structure);
    return structure;
  }
  
  float mfe_window(FILE *file=NULL)
  {
	  return vrna_mfe_window($self,file);
  }
  
  /*ONLY possible if USE_SVM is set
  float mfe_window_zscore(double min_z,FILE *file=NULL)
  {
	  return vrna_mfe_window_zscore($self,min_z,file);
  }*/
  
   /*##############
   * from eval.h
	###########*/
  
  
  float eval_structure(const char *structure){
	  return vrna_eval_structure($self,structure);
  }
  /*calculate MFE of given pairtable*/
  float eval_structure_pt(std::vector<int> pt)
  {
	  std::vector<short> vc;
	  transform(pt.begin(), pt.end(), back_inserter(vc), convert_vecint2vecshort);
	  return vrna_eval_structure_pt($self,(const short*)&vc[0]);
  }
  
  
  /*MFE of given structure, but now with different FileHandler for verbose, NULL = STDOUT*/
  float eval_structure_verbose(char *structure, FILE *file)
  {
	  return vrna_eval_structure_verbose($self,structure,file);
  }
  
 /*MFE of given pairtable, with different FileHandler for verbose, Default value = NULL + STDOUT*/
  float eval_structure_pt_verbose(std::vector<int> pt, FILE *file)
  {
	  std::vector<short> vc;
	  transform(pt.begin(), pt.end(), back_inserter(vc), convert_vecint2vecshort);
	  return vrna_eval_structure_pt_verbose($self,(const short*)&vc[0],file);
  }
  
  /*returns the energy for a structure to a given set of alignment sequences*/
  float eval_covar_structure2(char * structure)
  {    
	  return vrna_eval_covar_structure($self, structure);
  }
  

  
  /*returns the energy of a loop specified by i to pt[i]*/
  float eval_loop_pt(int i, std::vector<int> pt)
  {
	  std::vector<short> vc;
	  transform(pt.begin(), pt.end(), back_inserter(vc), convert_vecint2vecshort);
	  return vrna_eval_loop_pt($self,i,(const short*)&vc[0]);
  }
  
  /*returns the energy change by introducing a move on a given structure*/
  float eval_move(const char *structure,int m1, int m2)
  {
	  return vrna_eval_move($self,structure,m1,m2);
  }
  /*returns the energy change by introducing a move on a given pairtable*/
  float eval_move_pt(std::vector<int> pt,int m1, int m2)
  {
	  std::vector<short> vc;
	  transform(pt.begin(), pt.end(), back_inserter(vc), convert_vecint2vecshort);
	  return vrna_eval_move_pt($self,((short*)&vc[0]),m1,m2);   /*attention here no cosnt short* as argument*/
  }
  

  
/*####
in centroid.h
######*/
  
  /*calculates the centroid structure for alignment, and the distance to it 
   NOT working because of segmentation fault
  double centroid(char *OUTPUT)
  {
	  std::cout << $self->length <<"\n" << $self->type << "\n" ;
	  double dist;
	  OUTPUT = vrna_centroid($self,&dist);
	  return dist;
  }*/


  

  /*##########
   from constraints.h
################*/
  
  void constraints_add(const char *constraint, unsigned int options=VRNA_OPTION_MFE)
  {
	  vrna_constraints_add($self,constraint, options);
  }
  
  void hc_init()
  {
	  vrna_hc_init($self);
  }
  /*Make a certain nucleotide unpaired*/
  void hc_add_up(int i, char option=VRNA_CONSTRAINT_CONTEXT_ALL_LOOPS)
  {
	  vrna_hc_add_up($self,i,option);
  }
  /*Enforce a nucleotide to be paired (upstream/downstream)*/
  void hc_add_bp_nonspecific(int i, int d, char option=VRNA_CONSTRAINT_CONTEXT_ALL_LOOPS)
  {
	  vrna_hc_add_bp_nonspecific($self,i,d,option);
  }
  
  /*Favorize/Enforce  a certain base pair (i,j)*/
  void hc_add_bp(int i, int j, char option= VRNA_CONSTRAINT_CONTEXT_ALL_LOOPS)
  {
	  vrna_hc_add_bp($self,i,j,option);
  } 
  
  
  int hc_add_from_db(const char *constraint, unsigned int options=VRNA_CONSTRAINT_DB_DEFAULT)
  {
	  return vrna_hc_add_from_db($self,constraint,options);
  }
  
  
  
  
  
  /*Soft contraints are not yet imoplemented*/
  void sc_remove()
  {
	  vrna_sc_remove($self);
  }
  void sc_init()
  {
	  vrna_sc_init($self);
  }
  
  
  int sc_add_SHAPE_deigan(std::vector<double> reactivities, double m, double b, unsigned int options=VRNA_OPTION_MFE)
  {
	 
	return vrna_sc_add_SHAPE_deigan($self,(const double *)&reactivities[0],m,b,options);
	  
  }
  
  

int sc_add_SHAPE_deigan_ali(std::vector<string> shape_files,
                                  std::vector<int> shape_file_association,
                                  double m,
                                  double b,
                                  unsigned int options=VRNA_OPTION_MFE)
{
	std::vector<const char*>  vc;
	transform(shape_files.begin(), shape_files.end(), back_inserter(vc), convert_vecstring2veccharcp);
	vc.push_back(NULL); /* mark end of vector */
	return vrna_sc_add_SHAPE_deigan_ali($self,(const char **) &vc[0], (const int *) &shape_file_association[0],m,b,options);
}

 
int sc_add_SHAPE_zarringhalam(std::vector<double> reactivities, double b, double default_value, const char * shape_conversion,unsigned int options=VRNA_OPTION_MFE)
{
	return vrna_sc_add_SHAPE_zarringhalam($self,(const double *) &reactivities[0],b,default_value,shape_conversion,options);
}

  
/*END constraints.h
#########################################*/
	
/*#######start ligand.h###*/

/*only double is argument energy of function, not float or double*/

int sc_add_hi_motif(const char *seq,
                      const char *structure,
                      double energy,
                      unsigned int options=VRNA_OPTION_MFE)
{
	return vrna_sc_add_hi_motif($self,seq,structure,energy,options);
}


/* return 1 or 0 if success and the base positions in a given structure if the given motif was found
%apply int *OUTPUT {int *i, int *j, int *k, int *l};  /* HERE more return parameters are defined
int sc_detect_hi_motif(const char *structure,
                        int *i,
                        int *j,
                        int *k,
                        int *l)*/
//   int sc_detect_hi_motif(const char *structure)                      
// {
// 	
// 	cout << $self->sc->data;
// 	int i=0;
// 	int j=0;
// 	int k=0;
// 	int l=0;
// 	
// 	cout << " i = " << i;
// 	cout << " j = " << j;
// 	cout << " k = " << k;
// 	cout << " l = " << l;
// 	cout << " &i = " << &i;
// 	cout << " &j = " << &j;
// 	cout << " &k = " << &k;
// 	cout << " &l = " << &l;
// 	
// 	
// 	int ret = vrna_sc_detect_hi_motif($self,structure,&i,&j,&k,&l);
// 	
// 	cout << " ret = " << ret;
// 	cout << " i = " << i;
// 	cout << " j = " << j;
// 	cout << " k = " << k;
// 	cout << " l = " << l;
// 	
// 	return ret;
// }






/* return 1 or 0 if success and the base positions in a givens tructure if the given motif was found*/
// %apply int *OUTPUT {int *i, int *j, int *k, int *l};  /* HERE more return parameters are defined*/
// int sc_get_hi_motif(    int *i,
//                         int *j,
//                         int *k,
//                         int *l)
// {
// 	
// 	int ret =  vrna_sc_get_hi_motif($self,i,j,k,l);
// 	cout << " ret = " << ret;
// 	cout << " i = " << *i;
// 	cout << " j = " << *j;
// 	cout << " k = " << *k;
// 	cout << " l = " << *l;
// 	return ret;
// }


  /* "HEADER" definitions for overloaded functions !!!IT IS NOT WORKING
##################################################*/
/*float eval_structure_verbose(const char *structure, FILE *file);
float eval_structure_verbose(const char *structure);
int testFunction(std::vector<string> st);
int testFunction(std::vector<string> st, FILE *file );
int testFunction(std::vector<string> st, std::vector<string> fg);
*/


}


/*
 *  Rename all the preprocessor macros defined in data_structures.h
 *  (wrapped as constants)
 */
%constant unsigned char STATUS_MFE_PRE  = VRNA_STATUS_MFE_PRE;
%constant unsigned char STATUS_MFE_POST = VRNA_STATUS_MFE_POST;
%constant unsigned char STATUS_PF_PRE   = VRNA_STATUS_PF_PRE;
%constant unsigned char STATUS_PF_POST  = VRNA_STATUS_PF_POST;

%constant unsigned int OPTION_DEFAULT   = VRNA_OPTION_DEFAULT;
%constant unsigned int OPTION_MFE       = VRNA_OPTION_MFE;
%constant unsigned int OPTION_PF        = VRNA_OPTION_PF;
%constant unsigned int OPTION_HYBRID    = VRNA_OPTION_HYBRID;
%constant unsigned int OPTION_EVAL_ONLY = VRNA_OPTION_EVAL_ONLY;
%constant unsigned int OPTION_WINDOW    = VRNA_OPTION_WINDOW;

%rename(basepair) vrna_basepair_t;

typedef struct {
  int i;
  int j;
} vrna_basepair_t;

%include <ViennaRNA/data_structures.h>


