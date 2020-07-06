#!/bin/bash

echo "Running classification models"

echo "Running Breast Cancer dataset"
$QHOME/l64/q reshpopt.q -fin datasets/class_breastcancer.csv -fout breastcancer -dtyp FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFB -targ targ -ptyp class

echo "Running IBM dataset"
$QHOME/l64/q reshpopt.q -fin datasets/class_ibm.csv -fout ibm -dtyp FBFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF -targ Attrition -ptyp class

echo "Running IRIS dataset"
$QHOME/l64/q reshpopt.q -fin datasets/class_iris.csv -fout iris -dtyp FFFFI -targ iris -ptyp class

echo "Running Shopping dataset"
$QHOME/l64/q reshpopt.q -fin datasets/class_shop.csv -fout shop -dtyp FFFFFFFFFFFFFFFFFB -targ Revenue -ptyp class

echo "Running SSDS dataset"
$QHOME/l64/q reshpopt.q -fin datasets/class_ssds.csv -fout ssds -dtyp FFFFFFFFFFFFFIFFFF -targ class -ptyp class

echo "Running Telco dataset"
$QHOME/l64/q reshpopt.q -fin datasets/class_telco.csv -fout telco -dtyp FFFFFFFFFFFFFFFFFFFFB -targ Churn -ptyp class

echo "Running regression models"

echo "\nRunning Fish dataset"
$QHOME/l64/q reshpopt.q -fin datasets/reg_fish.csv -fout fish -dtyp FFFFFFF -targ Weight -ptyp reg

echo "Running HR dataset"
$QHOME/l64/q reshpopt.q -fin datasets/reg_hr.csv -fout hr -dtyp FFFFFFFDFFFFFDFFFFFDFFFFFFFFF -targ PerformanceScore -ptyp reg

echo "Running Insurance dataset"
$QHOME/l64/q reshpopt.q -fin datasets/reg_insurance.csv -fout insurance -dtyp IBFIBFF -targ charges -ptyp reg

echo "Running car dataset"
$QHOME/l64/q reshpopt.q -fin datasets/reg_car.csv -fout car -dtyp IIFFFIII -targ Selling_Price -ptyp reg

echo "Comparisons complete."