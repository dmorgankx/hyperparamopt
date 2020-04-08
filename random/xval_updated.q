// load ML-Toolkit https://github.com/kxsystems/ml
\l ml/ml.q
.ml.loadfile`:init.q 

\d .ml

// ML-Toolkit changes - xval.q
xv.i.search:{[sf;k;n;x;y;f;p;t]
 if[t=0;:sf[k;n;x;y;f;p]];i:(0,floor count[y]*1-abs t)_$[t<0;xv.i.shuffle;til count@]y;
 (r;pr;f[pykwargs pr:first key desc avg each r:sf[k;n;x i 0;y i 0;f;p]](x;y)@\:/:i)}
xv.i.xvpf:{[pf;xv;k;n;x;y;f;p]p!(xv[k;n;x;y]f pykwargs@)@'p:pf p}
gs:1_xv.i.search@'xv.i.xvpf[{[p]key[p]!/:1_'(::)cross/value p}]@'xv.j
rs:1_xv.i.search@'xv.i.xvpf[{[p]flip rs.hpgen p}]@'xv.j

// generate random hyperparameters
/* x = dictionary with:
/*    - rs   = type of random search - sobol or random
/*    - seed = random seed, can be (::) - always the case for sobol
/*    - n    = number of points, can be (::)
/*    - p    = parameter list
rs.hpgen:{
  // set default values
  if[(::)~n:x`n;n:10];
  // find numerical parameters
  num:where any`uniform`loguniform=\:first each p:x`p;
  // find respective namespaces (ns) and append sequence or n pts to generate
  $[`sobol~typ:x`typ;
     [ns:`sbl;p,:num!p[num],'enlist each flip rs.i.sobol[count num;n]];
    typ~`random;
     [ns:`rdm;system"S ",string$[(::)~x`seed;42;x`seed];p,:num!p[num],'n];
    '"hyperparam type not supported"];
  // generate each hyperparameter
  rs.i.hpgen[ns;n]each p}

// sobol sequence generator from python
/* x = dimension
/* y = number of points
rs.i.sobol:.p.import[`sobol_seq;`:i4_sobol_generate;<]

// single list random hyperparameter generator
/* ns = namespace, either sbl or rdm
/* n  = number of points
/* p  = list of parameters
rs.i.hpgen:{[ns;n;p]
  // split parameters
  p:@[;0;first](0;1)_p,();
  // respective parameter generation
  $[`boolean~typ:p 0;n?0b;
    typ~`symbol ;n?p 1;
    typ~`uniform;rs.i.uniform[ns]. p 1;
    typ~`loguniform;rs.i.loguniform[ns]. p 1;
    '"please enter correct type"]}

// generate list of uniform numbers
/* ns  = namespace, either sbl or rdm
/* lo  = lower bound
/* hi  = higher bound
/* typ = type of parameter, e.g. "i", "f", etc
/* p   = additional parameters, e.g. sobol sequence (sbl) or number of points (rdm)
rs.i.uniform:{[ns;lo;hi;typ;p]
  if[hi<lo;'"upper bound must be greater than lower bound"];
  rs.i[ns][`uniform][lo;hi;typ;p]}

// generate list of log uniform numbers
/* params are same as rs.i.uniform, with lo and hi as powers of 10
rs.i.loguniform:xexp[10]rs.i.uniform::

// random uniform generator
rs.i.rdm.uniform:{[lo;hi;typ;n]lo+n?typ$hi-lo}

// sobol uniform generator
rs.i.sbl.uniform:{[lo;hi;typ;seq]typ$lo+(hi-lo)*seq}