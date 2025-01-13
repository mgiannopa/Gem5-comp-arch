# GEM5
Στην εργασία καλούμαστε να δουλέψουμε με τον εξομοιώτη gem5 σε ένα linux περιβάλλον με σκοπό την εξοικείωση και την καλύτερη κατανόηση του.
## Πρώτο μέρος:
Βασικά χαρακτηριστίκα από το script starter_se.py.  
- Voltage domain for system components: 3.3V
- Clock domain for system components: 1GHz
- Voltage for the CPU core: 1.2V
- Off Chip Memory bus type: SystemxBar
- Caches:
   - L1 cache: L1I (instruction cache), L1D (data cache)
   - Walk cache
   - L2 cache
   - Cache line size: 64 bytes
- Cpu type: atomic
- Cpu frequency: 1GHz
- Number of cores: 1
- Type of memory: DDR3_1600_8x8
- Number of memory channels: 2
- Number of memory ranks per channel: None
- Physical memory size: 2Gb

Πρέπει να σημειώθει ότι παρότι ορίζεται ο Cpu type  ως atomic μέσα στο αρχείο, κατά την εκτέλεση της εντολής εμείς τον ορίζουμε ως minor.  Ο Cpu type που ορίζεται στο  bash είναι και αυτός που τελικά ισχύει. Πιο αναλυτικά η εντολή  
` ./build/ARM/gem5.opt -d hello_result configs/example/arm/starter_se.py --cpu="minor" "tests/test-progs/hello/bin/arm/linux/hello" `  
## Επαλήθευση των χαρακτηριστικών με χρήση των αρχείων config.ini, config.json.
Αρχικά θα επικεντρωθούμε στο αρχείο config.ini. Για να βρούμε το αρχέιο πρέπει να πάμε στον φάκελο hello_results στον οποίο πριν κατά την εκτέλεση της εντολής μας ορίζουμε ρητά να αποθηκευτούν μέσα σε αυτόν τα αποτελέμσατα.  
Αναλυτικότερα:
- Στην γραμμή 15 του αρχείου: cache_line_size=64
- Στην γραμμή 25 του αρχείου: mem_ranges = 0:2147483647  
- Στην γραμμή 67 του αρχείου:  Type=MinorCPU
- Στις γραμμές 1223-1226 του αρχείου:
  - [system.cpu_cluster.voltage_domain]
  - type=VoltageDomain
  - eventq_index=0
  - voltage=1.2
- Στην γραμμή 1296 του αρχείου: ranks_per_channel=2
- Στην γραμμή 1419 του αρχείου: type=CoherentxBar για το membus
- Στις γραμμές 1450-1453 του αρχείου:
  - [system.voltage_domain]
  - type=VoltageDomain
  - eventq_index=0
  -voltage=3.3

Τώρα θα γίνει μελέτη του config.json.

- Στην γραμμή 30 του αρχείου: "type": "CoherentXBar"
- Στις γραμμές 102-107 του αρχείου: "voltage_domain":
  - "name":"voltage_domain"
  - "eventq_index": 0
  - "voltage": [3.3]
- Στην γραμμή 112 του αρχείου: "cache_line_size": 64
- Στις γραμμές 130-135 του αρχείου: "voltage_domain": 
  - "name": "voltage_domain"
  - "eventq_index": 0
  - "voltage": [1.2] 
- Στην γραμμή 431 του αρχείου : "type": "MinorCPU"
- Στην γραμμή 1771 του αρχείου : "ranks_per_channel": 2
- Στην γραμμή 1776 του αρχείου : "range": 0:2147483647 : 0 : 1048704
Επιβεβαιόνονται οι παρατηρήσεις που έγιναν στο config.ini και μέσω του config.json, όπως αναμενόταν.

### Τι είναι τα sim_seconds, sim_insts και host_inst_rate?
sim_seconds: Αναφέρεται στον συνολικό χρόνο που χρείαζεται η προσομοίωση για να τρέξει.(simulated time != real world time)  
sim_insts: Αναφέρεται στον αριθμό των εντολών που προσομοιώθηκαν.  
host_inst_rate: Αναφέρεται στον ρυθμός εντολών που εξομοιώνονται ανά δευτερόλεπτο του host machine.  
### Ποιό είναι το συνολικό νούμερο των «committed» εντολών?
Στο αρχέιο stats.txt αναφέρεται ότι ο αριθμός των commited εντολών είναι 5027. Το νούμερο αυτό διαφέρει από το τελικό νούμερο που παρουσίαζει ο gem5, καθώς δεν συμπεριλαμβάνει εντολές που εν τέλει απορρίφθηκαν όπως π.χ. από ένα εσφαλμένο branch prediction, έτσι ο συνολίκος αριθμός των εντολών που έγινε succesfully decoded είναι αρκετά μεγαλύτερος.  
### Πόσες φορές προσπελάστηκε η L2 cache?  
Ο συνολικός αριθμός προσπελάσεων (read+write) στην L2 είναι 474(γραμμή 842). Αν δεν μας δίνοταν αυτές οι πληροφορίες και με την υπόθεση ότι καθε miss της L1 cacahe οδηγεί σε προσπέλαση την L2 cache παρατηρόντας τα l1.misses προκύπτουν και τα accesses της L2. Με την ίδια νοοτροπία γνωρίζοντας πόσα είναι τα συνολικά cache accesses και γνωρίζοντας το miss rate της L1 μπορεί να προκύψει παρόμοιο συμπέρασμα.

## Πληροφορίες για Cpu models μέσω του gem5.org
- Simple CPU models  
  Το SimpleCPU είναι ένα λειτουργικό μοντέλο in-order που προορίζεται για περιπτώσεις όπου δεν απαιτείται λεπτομερές μοντέλο πιο αναλυτικά:
  - BaseSimpleCPU, δεν μπορεί να τρέξει από μόνη της.  Διατηρεί την αρχιτεκτονική του συστήματος και χρησιμοποιεί όλες τις συναρτήσεις που έχουν όλα τα μοντέλα SimpleCPU
  - AtomicSimpleCPU είναι η έκδοση του SimpleCPU που χρησιμοποιεί ατομικές προσπελάσεις μνήμης. Η AtomicSimpleCPU είναι κληρονομημένη από την BaseSimpleCPU, πολύ σηματνικό είναι ότι περίεχει συναρτήσεις tick, οι οποίες ορίζουν τι συμβαίνει σε κάθε κύκλο του επεξεργαστή.
  - TimingSimpleCPU είναι η έκδοση του SimpleCPU που χρησιμοποιεί χρονισμένες προσπελάσεις μνήμης. Καθυστερεί στις προσπελάσεις cache και περιμένει για την απάντηση από το σύστημα μνήμης πριν προχωρήσει.
- Minor CPU model  
  - MinorCPU, είναι ένα μοντέλο επεξεργαστή με in-order εκτέλεση που διαθέτει pipeline και παραμετροποιήσιμες δομές και συμπεριφορές, κατάλληλο για την ανάλυση και συσχέτιση μικρο-αρχιτεκτονικών χαρακτηριστικών επεξεργαστών. Η βασική του λειτουργία περιλαμβάνει τη μοντελοποίηση ενός επεξεργαστή με αυστηρή in-order εκτέλεση και τη δυνατότητα οπτικοποίησης των εντολών στην pipeline. Η φιλοσοφια σχεδίασης τους βασίζεται στο multithreading και data structures.

Αξίζει να σημειωθεί πως ο gem5 παρέχει και out of order cpu models με τα οποία δεν θα ασχοληθούμε στα πλαίσια της εργασίας.  

## Fibonacci program  
Αρχικά ορίζοντας μόνο τον τύπο του Cpu ηια MinorCPU έχουμε 0.00041 sim_seconds και το host_seconds 0.06 σύμφωνα με το stats.txt. Η εντολή που τρέξαμε έιναι :  
` ./build/ARM/gem5.opt configs/example/se.py --cpu-type=MinorCPU  --caches -c tests/test-progs/fiboarm`  
Πριν από αυτό έχει γίνει η μετατροπή του προγράμματος σύμφωνα με τις οδηγίες της εκφώνησης.  
Ομοίως αλλάζοντας τον τύπο της Cpu σε TimingSimpleCPU παίρνουμε sim_seconds 0.000051 και host_seconds 0.02. 
Οι 2 προσομοιώσεις έγιναν για μία ακολουθία Fibonacci 10 αριθμών. Αναμέναμε η χρήση MinorCPU να είναι πιο γρήγορη για τον προσομοιωτή βάση της pipeline αρχιτεκτονικής του, σε αντίθεση με το single-staged pipeline του TimingSimpleCPU.  
Δεν χρησιμοποιήθηκε αναδρομή κατά την συγγραφή του κώδικα για να μην επιβαρυνθεί ο προσομοιωτής από κάποιο απαιτητικό πρόγραμμα.  
Σε αυτό το κομμάτι θα γίνει re-run του fibonacci αλλάζοντας την συχνότητα λειτουργίας. Επιλέχθηκε το 0.1 GHz.
Για τον TimingSimpleCPU έχουμε sim_seconds 0.000277 και host_seconds 0.06.  
Για τον TimingSimpleCPU έχουμε sim_seconds 0.000527 και host_seconds 0.03.  
Οι χρόνοι αυξήθηκαν σημαντικά, εξαιτίας και της σημαντικής μείωσης της συχνότητας λειτουργίας. Για την αλλαγή της συχνότητας τρέχουμε την παραπάνω εντολή προσθέτωντας μετά την επιλογή του τύπου του επεξεργαστή.  
`--cpu-clock=0.1GHz`  
Τώρα θα γίνει εκ νέου re-run με αλλαγή του τύπου της μνήμης από DDR3_1600_8x8 σε DDR4_2400_8x8. 
Για MinorCPU έχουμε έχουμε sim_seconds 0.000039 και host_seconds 0.06.  
Για TimingSimpleCPU έχουμε sim_seconds 0.000051 και host_seconds 0.02.   
Παρατηρείται μία μικρή βελτίωση στον χρόνο της MinorCPU όχι όμως και στης TimingSimpleCPU, αυτό βασίζεται στο γεγονός ότι ο συγκεκριμένος τύπος CPU υποθέτει έναν στατικό χρόνο εκτέλεσης της εντολής. Για την αλλαγή του τύπου της μνήμης χρησιμοποίηθηκε η αρχική εντολή του Fibonacci προσθέτωντας μετά την επιλογή του τύπου του επεξεργαστή.  
`--mem-type=DDR4_2400_8x8`  
Σίγουρα ένας συνδυασμός της αύξησης τόσο της συχνότητας λειτουργίας όσο και της ταχύτητας της μνήμης θα έχει τα βέλτιστα αποτελέσματα.  
## Δεύτερο Μέρος :
### Χαρακτηριστικά επεξεργαστή (spec_cpu2006)  
Από το πρώτο benchmark που τρέχουμε και πηγαίνοντας στο config.ini παρατηρούμε:
- Στην γραμμή 15 : cache_line_size = 64
- Στην γραμμή 179/221 : size = 65536 (L1D)
- Στην γραμμή 218 : assoc = 2 (LD)
- Στην γραμμή 813/855 : size = 32768 (L1I)
- Στην γραμμή 852 : assoc = 2 (LI)
- Στην γραμμή 1018/1060 : size = 2097152 (L2)
- Στην γραμμή 1057 : assoc = 8 (L2)
### Benchmarks  
Τα γραφήματα των benchmarks υπάρχουν εντός του φακέλου `graphs_from_benchmarks` και ο κώδικας που χρησιμοποιήθηκε για την πραγωγή τους, εντός του φακέλου second_part.  Για την παραγωγή τους χρησιμοποιήθηκε το αντίστοιχο stats.txt file.  Οι εντολές για να τρέξουν τα benchmarks μας δίνονταν στην εκφώνηση και πιο συγκεκριμένα είναι:  
```bash
$ ./build/ARM/gem5.opt -d spec_results2/specbzip configs/example/se.py --cpu-type=MinorCPU --cpu-clock=1GHz --caches --l2cache -c spec_cpu2006/401.bzip2/src/specbzip -o "spec_cpu2006/401.bzip2/data/input.program 10" -I 100000000

$ ./build/ARM/gem5.opt -d spec_results2/specmcf configs/example/se.py --cpu-type=MinorCPU --cpu-clock=1GHz --caches --l2cache -c spec_cpu2006/429.mcf/src/specmcf -o "spec_cpu2006/429.mcf/data/inp.in" -I 100000000

$ ./build/ARM/gem5.opt -d spec_results2/spechmmer configs/example/se.py --cpu-type=MinorCPU --cpu-clock=1GHz --caches --l2cache -c spec_cpu2006/456.hmmer/src/spechmmer -o "--fixed 0 --mean 325 --num 45000 --sd 200 --seed 0 spec_cpu2006/456.hmmer/data/bombesin.hmm" -I 100000000

$ ./build/ARM/gem5.opt -d spec_results2/specsjeng configs/example/se.py --cpu-type=MinorCPU --cpu-clock=1GHz --caches --l2cache -c spec_cpu2006/458.sjeng/src/specsjeng -o "spec_cpu2006/458.sjeng/data/test.txt" -I 100000000

$ ./build/ARM/gem5.opt -d spec_results2/speclibm configs/example/se.py --cpu-type=MinorCPU --cpu-clock=1GHz --caches --l2cache -c spec_cpu2006/470.lbm/src/speclibm -o "20 spec_cpu2006/470.lbm/data/lbm.in 0 1 spec_cpu2006/470.lbm/data/100_100_130_cf_a.of" -I 100000000
```  
### Αλλαγή συχνότητας λειτουργίας  
Στην συνέχεια μας ζητήθηκε να αλλάξουμε την συχνότητα λειτουργίας αρχικά σε 1GHz και έπειτα σε 3GHz. Για τον σκόπο αυτό οι παραπάνω εντολές έγιναν re-run με την προσθήκη `--cpu-clock=1GHZ --cpu-clock=3GHz` αντίστοιχα. Τα αποτελέσματα τους βρίσκονται στους αντίστοιχους φακέλους. Αναλύοντας το αρχικό stats.txt παρατηρούμε 2 διαφορετικά domain clock:
- system.clk_domain.clock        1000 (γραμμή 289)  
- system.cpu_clk_domain.clock    500 (γραμμή 758)
Με την αλλαγή της συχνότητας σε 1GHz παρατηρούμε:  
- system.clk_domain.clock        1000 (γραμμή 289)  
- system.cpu_clk_domain.clock    1000 (γραμμή 758)
Ενώ με την αλλάγη της συχνότητας σε 3GHz:  
- system.clk_domain.clock        1000 (γραμμή 289)  
- system.cpu_clk_domain.clock    333 (γραμμή 758)  
(Χρησιμοποιήθηκε το system.cpu_clk_domain.clock και όχι το cpu_cluster.clk_domain.clock που μας δίνεται διότι δεν συναντάται στο αρχείο.)  
Καταλήγουμε στο συμπέρεσμα ότι η εντολή που χρησιμοποιήθηκε για την αλλαγή της συχνότητας επηρεάζει μόνο αυτή του επεξεργαστή και όχι του συνολικού συστήματος. Αυτό συμβαίνει λόγω της εντολής που χρησιμοποιούμε, αλλά και από το γεγονός πως ο επεξεργαστής πολλές φορές πρέπει να χρονίζεται πιο γρήγορα εξαιτίας και του όκγου των διεργασιών που επιτελεί. Η προσθήκη ενός ακομά επεξεργαστή θα τον έκανε να χρονίζεται με το system.cpu_clk_domain.clock. Μέσω του config.json βλέπουμε ότι οποισδήποτε χρονισμός αφορά μέρος του επεξεργαστή κληρονομεί το ρολόι σύμφωνα με το `system.cpu_clk_domain.clock`, ενώ οτιδήποτε άλλο (πχ μνήμες) σύμφωνα εμ το `system.clk_domain.clock`.

   
  
 

















