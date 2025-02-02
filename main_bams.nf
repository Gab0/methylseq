#!/usr/bin/env nextflow
/*
========================================================================================
						 nf-core/methylseq
========================================================================================
 nf-core/methylseq Analysis Pipeline.
 #### Homepage / Documentation
 https://github.com/nf-core/methylseq
----------------------------------------------------------------------------------------
*/

def helpMessage() {
	log.info nfcoreHeader()
	log.info"""

	Usage:

	The typical command for running the pipeline is as follows:

	nextflow run nf-core/methylseq --reads '*_R{1,2}.fastq.gz' -profile docker

	Mandatory arguments:
	  --aligner [str]                   Alignment tool to use (default: bismark)
											Available: bismark, bismark_hisat, bwameth, biscuit
	  --reads [file]                    Path to input data (must be surrounded with quotes)
	  --merge_reads						Specifies that input are many fastq files that need to be merged. Merging by basename that ends in the first '--separator'
	  --separator						The separator for defining the base file name for merging. Defaulat is: '_'
	  --bams [file] 					Path to input bam files data, downstream analysis via biscuit aligner. Files must be sorted by coordinates, indexed and duplicate-marked. If this parameter is set, the '--reads' is ignored.
	  -profile [str]                    Configuration profile to use. Can use multiple (comma separated)
											Available: conda, docker, singularity, test, awsbatch, <institute> and more

	Options:
	 --genome [str]                     Name of iGenomes reference
	 --single_end [bool]                Specifies that the input is single end reads
	 --comprehensive [bool]             Output information for all cytosine contexts
	 --cytosine_report [bool]           Output stranded cytosine report during Bismark's bismark_methylation_extractor step.
	 --ignore_flags [bool]              Run MethylDackel with the flag to ignore SAM flags.
	 --meth_cutoff [int]                Specify a minimum read coverage to report a methylation call during Bismark's bismark_methylation_extractor step.
	 --min_depth [int]                  Specify a minimum read coverage for MethylDackel to report a methylation call or for biscuit pileup.
	 --methyl_kit [bool]                Run MethylDackel with the --methyl_kit flag to produce files suitable for use with the methylKit R package.
	 --skip_deduplication [bool]        Skip deduplication step after alignment. This is turned on automatically if --rrbs is specified
	 --non_directional [bool]           Run alignment against all four possible strands
	 --save_align_intermeds [bool]      Save aligned intermediates to results directory
	 --save_trimmed [bool]              Save trimmed reads to results directory
	 --save_pileup_file [bool]          Save vcf-pileup and index-vcf files from biscuit aligner to results directory
	 --save_snp_file					Save SNP bed-file from biscuit to results directory. Relevant only if '--epiread' is specified
	 --unmapped [bool]                  Save unmapped reads to fastq files
	 --relax_mismatches [bool]          Turn on to relax stringency for alignment (set allowed penalty with --num_mismatches)
	 --num_mismatches [float]           0.6 will allow a penalty of bp * -0.6 - for 100bp reads (bismark default is 0.2)
	 --known_splices [file]             Supply a .gtf file containing known splice sites (bismark_hisat only)
	 --slamseq [bool]                   Run bismark in SLAM-seq mode
	 --local_alignment [bool]           Allow soft-clipping of reads (potentially useful for single-cell experiments)
	 --bismark_align_cpu_per_multicore [int] Specify how many CPUs are required per --multicore for bismark align (default = 3)
	 --bismark_align_mem_per_multicore [str] Specify how much memory is required per --multicore for bismark align (default = 13.GB)
	 --soloWCGW_file [path]             soloWCGW file, to intersect with methyl_extract bed file. soloWCGW for hg38 can be downlaod from: www.cse.huji.ac.il/~ekushele/solo_WCGW_cpg_hg38.bed. EXPERMINTAL!
	--assets_dir [path]                Assets directory for biscuit_QC, REQUIRED IF IN BISCUIT ALIGNER. can be found at: https://www.cse.huji.ac.il/~ekushele/assets.html
	 --epiread [bool]                   Convert bam to biscuit epiread format
	 --whitelist [file]				The complement of blacklist, needed for SNP extraction For more instuctions: https://www.cse.huji.ac.il/~ekushele/assets.html#whitelist
	 --common_dbsnp	[file]				Common dbSNP for the relevant genome, for SNP filteration
	 --cpg_file [file]                  Path to CpG file for the relevant genome (0-besed coordinates, not compressed)
	 --debug_epiread                    Debug epiread merging for paired end-keep original epiread file and merged epiread file in debug mode
	 --debug_epiread_merging            Debug epiread merging. Output merged epiread in debug mode

	References                          If not specified in the configuration file or you wish to overwrite any of the references.
	  --fasta [file]                    Path to fasta reference
	  --fasta_index [path]              Path to Fasta Index
	  --bismark_index [path]            Path to Bismark index
	  --bwa_biscuit_index [path]        Path to Biscuit index
	  --bwa_meth_index [path]           Path to bwameth index
	  --save_reference [bool]           Save reference(s) to results directory

	Trimming options:
	 --skip_trimming [bool]             Skip read trimming
	 --clip_r1 [int]                    Trim the specified number of bases from the 5' end of read 1 (or single-end reads).
	 --clip_r2 [int]                    Trim the specified number of bases from the 5' end of read 2 (paired-end only).
	 --three_prime_clip_r1 [int]        Trim the specified number of bases from the 3' end of read 1 AFTER adapter/quality trimming
	 --three_prime_clip_r2 [int]        Trim the specified number of bases from the 3' end of read 2 AFTER adapter/quality trimming
	 --rrbs [bool]                      Turn on if dealing with MspI digested material.

	Trimming presets:
	 --pbat [bool]
	 --single_cell [bool]
	 --epignome [bool]
	 --accell [bool]
	 --zymo [bool]
	 --cegx [bool]

	Other options:
	 --outdir [file]                    The output directory where the results will be saved
	 --email [email]                    Set this parameter to your e-mail address to get a summary e-mail with details of the run sent to you when the workflow exits
	 --email_on_fail [email]            Same as --email, except only send mail if the workflow is not successful
	 --max_multiqc_email_size [str]     Threshold size for MultiQC report to be attached in notification email. If file generated by pipeline exceeds the threshold, it will not be attached (Default: 25MB)
	 -name [str]                        Name for the pipeline run. If not specified, Nextflow will automatically generate a random mnemonic

	AWSBatch options:
	  --awsqueue [str]                  The AWSBatch JobQueue that needs to be set when running on AWSBatch
	  --awsregion [str]                 The AWS Region for your AWS Batch job to run on
	  --awscli [str]                    Path to the AWS CLI tool

	""".stripIndent()
}

// Show help message
if (params.help) {
	helpMessage()
	exit 0
}

// Validate inputs
assert params.aligner == 'bwameth' || params.aligner == 'bismark' || params.aligner == 'bismark_hisat' || params.aligner == 'biscuit' : "Invalid aligner option: ${params.aligner}. Valid options: 'bismark', 'bwameth', 'bismark_hisat', 'biscuit'"

/*
 * SET UP CONFIGURATION VARIABLES
 */

// These params need to be set late, after the iGenomes config is loaded
params.bismark_index = params.genome ? params.genomes[ params.genome ].bismark ?: false : false
params.bwa_meth_index = params.genome ? params.genomes[ params.genome ].bwa_meth ?: false : false
params.fasta = params.genome ? params.genomes[ params.genome ].fasta ?: false : false
params.fasta_index = params.genome ? params.genomes[ params.genome ].fasta_index ?: false : false
params.merge_reads=false
params.separator = '_L'
assembly_name = (params.fasta.toString().lastIndexOf('/') == -1) ?: params.fasta.toString().substring( params.fasta.toString().lastIndexOf('/')+1)

// Check if genome exists in the config file
if (params.genomes && params.genome && !params.genomes.containsKey(params.genome)) {
	exit 1, "The provided genome '${params.genome}' is not available in the iGenomes file. Currently the available genomes are ${params.genomes.keySet().join(", ")}"
}

Channel
	.fromPath("$baseDir/assets/where_are_my_files.txt", checkIfExists: true)
	.into { ch_wherearemyfiles_for_trimgalore; ch_wherearemyfiles_for_alignment }

ch_splicesites_for_bismark_hisat_align = params.known_splices ? Channel.fromPath("${params.known_splices}", checkIfExists: true).collect() : file('null')


if( params.aligner =~ /bismark/ && !params.bams ){
	assert params.bismark_index || params.fasta : "No reference genome index or fasta file specified"
	ch_wherearemyfiles_for_alignment.into { ch_wherearemyfiles_for_bismark_align; ch_wherearemyfiles_for_bismark_samtools_sort; ch_wherearemyfiles_for_bismark_dedup_samtools_sort; }

	Channel
		.fromPath(params.fasta, checkIfExists: true)
		.ifEmpty { exit 1, "fasta file not found : ${params.fasta}" }
		.into { ch_fasta_for_makeBismarkIndex; ch_fasta_for_picard }  
	
	if( params.bismark_index ){
		Channel
			.fromPath(params.bismark_index, checkIfExists: true)
			.ifEmpty { exit 1, "Bismark index file not found: ${params.bismark_index}" }
			.into { ch_bismark_index_for_bismark_align; ch_bismark_index_for_bismark_methXtract }
		ch_fasta_for_makeBismarkIndex.close()
	}
	   
}
else if( params.aligner == 'bwameth' || params.aligner == 'biscuit' || params.bams){ 
	assert params.fasta : "No Fasta reference specified!"
	ch_wherearemyfiles_for_alignment.into { ch_wherearemyfiles_for_bwamem_align; ch_wherearemyfiles_for_biscuit_align; ch_wherearemyfiles_for_samtools_sort_index_flagstat; ch_wherearemyfiles_for_samblaster }

	Channel
		.fromPath(params.fasta, checkIfExists: true)
		.ifEmpty { exit 1, "fasta file not found : ${params.fasta}" }
		.into { ch_fasta_for_makeBwaMemIndex; ch_fasta_for_makeFastaIndex; ch_fasta_for_methyldackel; ch_fasta_for_pileup; ch_fasta_for_epiread; ch_fasta_for_biscuitQC; ch_fasta_for_picard}

	if( params.bwa_meth_index ){
		Channel
			.fromPath("${params.bwa_meth_index}*", checkIfExists: true)
			.ifEmpty { exit 1, "bwa-meth index file(s) not found: ${params.bwa_meth_index}" }
			.set { ch_bwa_meth_indices_for_bwamem_align }
		ch_fasta_for_makeBwaMemIndex.close()
	}

	 if( params.bwa_biscuit_index ){
		Channel
			.fromPath("${params.bwa_biscuit_index}*", checkIfExists: true)
			.ifEmpty { exit 1, "bwa (biscuit) index file(s) not found: ${params.bwa_biscuit_index}" }
			.set { ch_bwa_index_for_biscuit  }
		ch_fasta_for_makeBwaMemIndex.close()
	}

	if( params.fasta_index ){
		Channel
			.fromPath(params.fasta_index, checkIfExists: true)
			.ifEmpty { exit 1, "fasta index file not found: ${params.fasta_index}" }
			.into { ch_fasta_index_for_methyldackel; ch_fasta_index_for_biscuitQC; ch_fasta_index_for_createVCF; ch_fasta_index_for_epiread }
		ch_fasta_for_makeFastaIndex.close()
	}
  }

if( ( params.aligner == 'biscuit' || params.bams) && params.assets_dir ) {
	//assert params.assets_dir : "Assets directory for biscuit-QC was not specified!"

	Channel
		.fromPath("${params.assets_dir}", checkIfExists: true)
		.ifEmpty { exit 1, "Assets directory for biscuit QC not found: ${params.assets_dir}" }
        .into { ch_assets_dir_for_biscuit_qc; ch_assets_dir_with_cpg_for_epiread }
}


if( workflow.profile == 'uppmax' || workflow.profile == 'uppmax_devel' ){
	if( !params.project ) exit 1, "No UPPMAX project ID found! Use --project"
}

// Has the run name been specified by the user?
//  this has the bonus effect of catching both -name and --name
custom_runName = params.name
if (!(workflow.runName ==~ /[a-z]+_[a-z]+/)) {
	custom_runName = workflow.runName
}

// Trimming presets
clip_r1 = params.clip_r1
clip_r2 = params.clip_r2
three_prime_clip_r1 = params.three_prime_clip_r1
three_prime_clip_r2 = params.three_prime_clip_r2
if(params.pbat){
	clip_r1 = 9
	clip_r2 = 9
	three_prime_clip_r1 = 9
	three_prime_clip_r2 = 9
}
else if( params.single_cell ){
	clip_r1 = 6
	clip_r2 = 6
	three_prime_clip_r1 = 6
	three_prime_clip_r2 = 6
}
else if( params.epignome ){
	clip_r1 = 8
	clip_r2 = 8
	three_prime_clip_r1 = 8
	three_prime_clip_r2 = 8
}
else if( params.accel || params.zymo ){
	clip_r1 = 10
	clip_r2 = 15
	three_prime_clip_r1 = 10
	three_prime_clip_r2 = 10
}
else if( params.cegx ){
	clip_r1 = 6
	clip_r2 = 6
	three_prime_clip_r1 = 2
	three_prime_clip_r2 = 2
}

if (workflow.profile.contains('awsbatch')) {
	// AWSBatch sanity checking
	if (!params.awsqueue || !params.awsregion) exit 1, "Specify correct --awsqueue and --awsregion parameters on AWSBatch!"
	// Check outdir paths to be S3 buckets if running on AWSBatch
	// related: https://github.com/nextflow-io/nextflow/issues/813
	if (!params.outdir.startsWith('s3:')) exit 1, "Outdir not on S3 - specify S3 Bucket to run on AWSBatch!"
	// Prevent trace files to be stored on S3 since S3 does not support rolling files.
	if (params.tracedir.startsWith('s3:')) exit 1, "Specify a local tracedir or run without trace! S3 cannot be used for tracefiles."
}

// Stage config files
ch_multiqc_config = file("$baseDir/assets/multiqc_config.yaml", checkIfExists: true)
ch_multiqc_custom_config = params.multiqc_config ? Channel.fromPath(params.multiqc_config, checkIfExists: true) : Channel.empty()
ch_output_docs = file("$baseDir/docs/output.md", checkIfExists: true)

/*
 * Create a channel for input read files
 */
assert params.readPaths || params.reads || params.bams : "Either reads or bams files must be specified!"
if (params.readPaths) {
	if (params.single_end) {
		Channel
			.from(params.readPaths)
			.map { row -> [ row[0], [ file(row[1][0], checkIfExists: true) ] ] }
			.ifEmpty { exit 1, "params.readPaths was empty - no input files supplied" }
			.into { ch_read_files_for_fastqc; ch_read_files_for_trim_galore }
	} else {
		Channel
			.from(params.readPaths)
			.map { row -> [ row[0], [ file(row[1][0], checkIfExists: true), file(row[1][1], checkIfExists: true) ] ] }
			.ifEmpty { exit 1, "params.readPaths was empty - no input files supplied" }
			.into { ch_read_files_for_fastqc; ch_read_files_for_trim_galore }
	}
} else if (params.reads) {
	if (!params.merge_reads) {
		Channel
			.fromFilePairs( params.reads, size: params.single_end ? 1 : 2 )
			.ifEmpty { exit 1, "Cannot find any reads matching: ${params.reads}\nNB: Path needs to be enclosed in quotes!\nIf this is single-end data, please specify --single_end on the command line." }
			.into { ch_read_files_for_fastqc; ch_read_files_for_trim_galore }
	}
	else { //many reads, needs to be merged
		Channel
			.fromFilePairs( params.reads )
			.ifEmpty { exit 1, "Cannot find any reads matching: ${params.reads}\nNB: Path needs to be enclosed in quotes!\nIf this is single-end data, please specify --single_end on the command line." }
			.map { row -> tuple(row[0].substring(0,row[0].indexOf(params.separator)), file(row[1][0]),file(row[1][1])) }
			//.flatMap { key, files -> [  ["${key.substring(0,key.indexOf('___'))}_1.fastq.gz",  files[0]  ],["${key.substring(0,key.indexOf('___'))}_2.fastq.gz", files[1] ] ] }

			// .collectFile() 
			// //.toList() 
			// .buffer(size: 2)  
			// .map { row -> [row[0].simpleName - ~/(_1)/ , [ file(row[0]), file(row[1]) ] ] }
			// .into { ch_read_files_for_fastqc; ch_read_files_for_trim_galore }
				 .groupTuple()
		.set { ch_concatinate_fastq}
		
		process concatenate_fastq {    
			tag "$name"

			input:
			set val(name), file(read1), file(read2) from ch_concatinate_fastq 

			output:
			set val(name), file('*fastq.gz') into ch_read_files_for_fastqc,ch_read_files_for_trim_galore

			script:
			"""
			cat $read1 > ${name}_1.fastq.gz
			cat $read2 > ${name}_2.fastq.gz		  
			"""
		}
  

	}
	
} else {
	ch_read_files_for_fastqc = Channel.empty() 
	ch_read_files_for_trim_galore = Channel.empty() 
}

if (params.soloWCGW_file) {
	Channel
	.fromPath(params.soloWCGW_file, checkIfExists: true)
	.ifEmpty { exit 1, "Cannot find any soloWCGW_file file matching: ${params.soloWCGW_file}\n" }
	.set { ch_soloWCGW_for_biscuitVCF; }
}
if (params.epiread) {
	if (params.whitelist) {
		Channel
		.fromPath(params.whitelist, checkIfExists: true)
		.ifEmpty { exit 1, "Cannot find any whitelist file matching: ${params.whitelist}\nWhitelist file is mandatory if epiread file conversion is required" }
		.into { ch_whitelist_for_SNP; ch_whitelist_for_epiread}
	}

	if (params.common_dbsnp) {
		Channel
		.fromPath(params.common_dbsnp,  checkIfExists: true)
		.ifEmpty { exit 1, "Cannot find any dbSNP file matching: ${params.common_dbsnp}\n" }
		.set { ch_commonSNP_for_SNP; }
	}
	// if (!params.single_end)
		// assert params.cpg_file: "No CpG file specified"

	// ch_cpg_for_epiread= Channel.empty()
	// if (!params.single_end) {
			// if (params.cpg_file) {
				// Channel
					// .fromPath(params.cpg_file, checkIfExists: true)
					// .ifEmpty { exit 1, "CpG file not found : ${params.cpg_file}" }
					// .into { ch_cpg_for_epiread; ch_cpg_file_for_cpg_index; }
				// }
	// }
}

// Header log info
log.info nfcoreHeader()
def summary = [:]
summary['Run Name']  = custom_runName ?: workflow.runName
if (!params.bams) summary['Reads']     = params.reads
if (params.bams) summary['Bams']	= params.bams
summary['Aligner']   = params.aligner
if (!params.bams) summary['Data Type'] = params.single_end ? 'Single-End' : 'Paired-End'
if(params.known_splices)     summary['Spliced alignment'] =  'Yes'
if(params.slamseq)           summary['SLAM-seq'] = 'Yes'
if(params.local_alignment)   summary['Local alignment'] = 'Yes'
if(params.genome)            summary['Genome']    = params.genome
if(params.bismark_index)     summary['Bismark Index'] = params.bismark_index
if(params.bwa_meth_index)    summary['BWA-Meth Index'] = "${params.bwa_meth_index}*"
if(params.bwa_biscuit_index) summary['BWA Index'] = "${params.bwa_biscuit_index}*"
if(params.fasta)             summary['Fasta Ref'] = params.fasta
if(params.fasta_index)       summary['Fasta Index'] = params.fasta_index
if(params.rrbs)              summary['RRBS Mode'] = 'On'
if(params.relax_mismatches)  summary['Mismatch Func'] = "L,0,-${params.num_mismatches} (Bismark default = L,0,-0.2)"
if(params.skip_trimming)     summary['Trimming Step'] = 'Skipped'
if(params.pbat)              summary['Trim Profile'] = 'PBAT'
if(params.single_cell)       summary['Trim Profile'] = 'Single Cell'
if(params.epignome)          summary['Trim Profile'] = 'TruSeq (EpiGnome)'
if(params.accel)             summary['Trim Profile'] = 'Accel-NGS (Swift)'
if(params.zymo)              summary['Trim Profile'] = 'Zymo Pico-Methyl'
if(params.cegx)              summary['Trim Profile'] = 'CEGX'
summary['Trimming']          = "5'R1: $clip_r1 / 5'R2: $clip_r2 / 3'R1: $three_prime_clip_r1 / 3'R2: $three_prime_clip_r2"
summary['Deduplication']     = params.skip_deduplication || params.rrbs ? 'No' : 'Yes'
summary['Directional Mode']  = params.single_cell || params.zymo || params.non_directional ? 'No' : 'Yes'
summary['All C Contexts']    = params.comprehensive ? 'Yes' : 'No'
summary['Cytosine report']   = params.cytosine_report ? 'Yes' : 'No'
if(params.min_depth)         summary['Minimum Depth'] = params.min_depth
if(params.ignore_flags)      summary['MethylDackel'] = 'Ignoring SAM Flags'
if(params.methyl_kit)        summary['MethylDackel'] = 'Producing methyl_kit output'
save_intermeds = [];         
if(params.save_reference)    save_intermeds.add('Reference genome build')
if(params.save_trimmed)      save_intermeds.add('Trimmed FastQ files')
if(params.unmapped)          save_intermeds.add('Unmapped reads')
if(params.save_align_intermeds) save_intermeds.add('Intermediate BAM files')
if(params.save_pileup_file)  save_intermeds.add('Pileup files') 
if(params.save_snp_file)     save_intermeds.add('SNP bed-files') 
if(save_intermeds.size() > 0) summary['Save Intermediates'] = save_intermeds.join(', ')
debug_mode = [];
if(params.debug_epiread)	debug_mode.add('Debug epiread step')
if(params.debug_epiread_merging) debug_mode.add('Debug epiread merging')
if(debug_mode.size() > 0) summary['Debug mode'] = debug_mode.join(', ')
if(params.bismark_align_cpu_per_multicore) summary['Bismark align CPUs per --multicore'] = params.bismark_align_cpu_per_multicore
if(params.bismark_align_mem_per_multicore) summary['Bismark align memory per --multicore'] = params.bismark_align_mem_per_multicore
if(params.assets_dir)        summary['Assets Directory'] = params.assets_dir	
if(params.soloWCGW_file)     summary['soloWCGW File'] = params.soloWCGW_file
if(params.whitelist)         summary['Whitelist'] = params.whitelist
if(params.common_dbsnp)      summary['Common SNP'] = params.common_dbsnp
// if(params.cpg_file)			 summary['CpG File'] = params.cpg_file
if(params.epiread)           summary['Epiread'] = 'Yes'
if(params.merge_reads) 		summary['Separator']= params.separator
summary['Output dir']        = params.outdir
summary['Launch dir']        = workflow.launchDir
summary['Working dir']       = workflow.workDir
summary['Pipeline dir']      = workflow.projectDir
summary['User']              = workflow.userName
summary['Config Profile']    = workflow.profile
if (workflow.containerEngine) summary['Container'] = "$workflow.containerEngine - $workflow.container"
if (workflow.profile.contains('awsbatch')) {
	summary['AWS Region']    = params.awsregion
	summary['AWS Queue']     = params.awsqueue
	summary['AWS CLI']       = params.awscli
}
if(params.project) summary['Cluster Project'] = params.project
if (params.config_profile_description) summary['Config Description'] = params.config_profile_description
if (params.config_profile_contact)     summary['Config Contact']     = params.config_profile_contact
if (params.config_profile_url)         summary['Config URL']         = params.config_profile_url
summary['Max Resources']     = "$params.max_memory memory, $params.max_cpus cpus, $params.max_time time per job"
if(params.email)             summary['E-mail Address'] = params.email
if(params.email_on_fail)     summary['E-mail on failure'] = params.email_on_fail
log.info summary.collect { k,v -> "${k.padRight(18)}: $v" }.join("\n")
log.info "-\033[2m--------------------------------------------------\033[0m-"

// Check the hostnames against configured profiles
checkHostname()

Channel.from(summary.collect{ [it.key, it.value] })
	.map { k,v -> "<dt>$k</dt><dd><samp>${v ?: '<span style=\"color:#999999;\">N/A</a>'}</samp></dd>" }
	.reduce { a, b -> return [a, b].join("\n            ") }
	.map { x -> """
	id: 'nf-core-methylseq-summary'
	description: " - this information is collected when the pipeline is started."
	section_name: 'nf-core/methylseq Workflow Summary'
	section_href: 'https://github.com/nf-core/methylseq'
	plot_type: 'html'
	data: |
        <dl class=\"dl-horizontal\">
            $x
        </dl>
    """.stripIndent() }
	.set { ch_workflow_summary } 	

/*
 * Parse software version numbers
 */
process get_software_versions {
	publishDir "${params.outdir}/pipeline_info", mode: 'copy',
		saveAs: { filename ->
					  if (filename.indexOf(".csv") > 0) filename
					  else null
				}

	output:
	file 'software_versions_mqc.yaml' into ch_software_versions_yaml_for_multiqc
	file "software_versions.csv"

	script:
	"""
	echo "$workflow.manifest.version" &> v_ngi_methylseq.txt
	echo "$workflow.nextflow.version" &> v_nextflow.txt
	bismark_genome_preparation --version &> v_bismark_genome_preparation.txt
	fastqc --version &> v_fastqc.txt
	cutadapt --version &> v_cutadapt.txt
	trim_galore --version &> v_trim_galore.txt
	bismark --version &> v_bismark.txt
	deduplicate_bismark --version &> v_deduplicate_bismark.txt
	bismark_methylation_extractor --version &> v_bismark_methylation_extractor.txt
	bismark2report --version &> v_bismark2report.txt
	bismark2summary --version &> v_bismark2summary.txt
	samtools --version &> v_samtools.txt
	hisat2 --version &> v_hisat2.txt
	bwa &> v_bwa.txt 2>&1 || true
	bwameth.py --version &> v_bwameth.txt
	picard MarkDuplicates --version &> v_picard_markdups.txt 2>&1 || true
	picard CreateSequenceDictionary --version &> v_picard_createseqdict.txt 2>&1 || true
	picard CollectInsertSizeMetrics --version &> v_picard_collectinssize.txt 2>&1 || true
	picard CollectGcBiasMetrics --version &> v_picard_collectgcbias.txt 2>&1 || true
	MethylDackel --version &> v_methyldackel.txt
	qualimap --version &> v_qualimap.txt || true
	preseq &> v_preseq.txt
	multiqc --version &> v_multiqc.txt
	samblaster --version &> v_samblaster.txt
	biscuit &>v_biscuit.txt 2>&1 || true 
	bcftools --version &> v_bcftools.txt	
	scrape_software_versions.py &> software_versions_mqc.yaml
	"""
}

/*
 * PREPROCESSING - Build Bismark index
 */
if( !params.bismark_index && params.aligner =~ /bismark/ && !params.bams ){
	process makeBismarkIndex {
		publishDir path: { params.save_reference ? "${params.outdir}/reference_genome" : params.outdir },
				   saveAs: { params.save_reference ? it : null }, mode: 'copy'

		input:
		file fasta from ch_fasta_for_makeBismarkIndex

		output:
		file "BismarkIndex" into ch_bismark_index_for_bismark_align, ch_bismark_index_for_bismark_methXtract

		script:
		aligner = params.aligner == 'bismark_hisat' ? '--hisat2' : '--bowtie2'
		slam = params.slamseq ? '--slam' : ''
		"""
		mkdir BismarkIndex
		cp $fasta BismarkIndex/
		bismark_genome_preparation $aligner $slam BismarkIndex
		"""
	}
}

/*
 * PREPROCESSING - Build bwa-mem index
 */
if( !params.bwa_meth_index && params.aligner == 'bwameth' && !params.bams ){
	process makeBwaMemIndex {
		tag "$fasta"
		publishDir path: "${params.outdir}/reference_genome", saveAs: { params.save_reference ? it : null }, mode: 'copy'

		input:
		file fasta from ch_fasta_for_makeBwaMemIndex

		output:
		file "${fasta}*" into ch_bwa_meth_indices_for_bwamem_align

		script:
		"""
		bwameth.py index $fasta
		"""
	}
}

/*
 * PREPROCESSING - Build bwa index, using biscuit
 */
if( !params.bwa_biscuit_index && params.aligner == 'biscuit' && !params.bams ){
	process makeBwaBISCUITIndex {
		tag "$fasta"
		publishDir path: "${params.outdir}/reference_genome", saveAs: { params.save_reference ? it : null }, mode: 'copy'

		input:
		file fasta from ch_fasta_for_makeBwaMemIndex

		output:
		file "${fasta}*" into ch_bwa_index_for_biscuit

		script:
		"""
		mkdir BiscuitIndex
		cp $fasta BiscuitIndex/
		biscuit index $fasta
		cp ${fasta}* BiscuitIndex
		"""
	}
}

/*
 * PREPROCESSING - Index Fasta file
 */
if( !params.fasta_index && params.aligner == 'bwameth' ||  !params.fasta_index && params.aligner == 'biscuit' ){
	process makeFastaIndex {
		tag "$fasta"
		publishDir path: "${params.outdir}/reference_genome", saveAs: { params.save_reference ? it : null }, mode: 'copy'

		input:
		file fasta from ch_fasta_for_makeFastaIndex

		output:
		file "${fasta}.fai" into ch_fasta_index_for_methyldackel,ch_fasta_index_for_biscuitQC,ch_fasta_index_for_createVCF,ch_fasta_index_for_epiread

		script:
		"""
		samtools faidx $fasta
		"""
	}
}


/*
 * STEP 1 - FastQC
 */
process fastqc {
	tag "$name"
	label 'process_medium'
	publishDir "${params.outdir}/fastqc", mode: 'copy',
		saveAs: { filename ->
					  filename.indexOf(".zip") > 0 ? "zips/$filename" : "$filename"
				}

	input:
	set val(name), file(reads) from ch_read_files_for_fastqc

	output:
	file '*_fastqc.{zip,html}' into ch_fastqc_results_for_multiqc

	when: params.reads && !params.bams
	
	script:
	"""
	fastqc --quiet --threads $task.cpus $reads
	"""
}

/*
 * STEP 2 - Trim Galore!
 */
if( params.skip_trimming ){
	ch_trimmed_reads_for_alignment = ch_read_files_for_trim_galore
	ch_trim_galore_results_for_multiqc = Channel.from(false)
} else {
	process trim_galore {
		tag "$name"
		publishDir "${params.outdir}/trim_galore", mode: 'copy',
			saveAs: {filename ->
				if( filename.indexOf("_fastqc") > 0 ) "FastQC/$filename"
				else if( filename.indexOf("trimming_report.txt" ) > 0) "logs/$filename"
				else if( !params.save_trimmed && filename == "where_are_my_files.txt" ) filename
				else if( params.save_trimmed && filename != "where_are_my_files.txt" ) filename
				else null
			}

		input:
		set val(name), file(reads) from ch_read_files_for_trim_galore
		file wherearemyfiles from ch_wherearemyfiles_for_trimgalore.collect()

		output:
		set val(name), file('*fq.gz') into ch_trimmed_reads_for_alignment
		file "*trimming_report.txt" into ch_trim_galore_results_for_multiqc
		file "*_fastqc.{zip,html}"
		file "where_are_my_files.txt"
		
		when: params.reads && !params.bams

		script:
		def c_r1 = clip_r1 > 0 ? "--clip_r1 $clip_r1" : ''
		def c_r2 = clip_r2 > 0 ? "--clip_r2 $clip_r2" : ''
		def tpc_r1 = three_prime_clip_r1 > 0 ? "--three_prime_clip_r1 $three_prime_clip_r1" : ''
		def tpc_r2 = three_prime_clip_r2 > 0 ? "--three_prime_clip_r2 $three_prime_clip_r2" : ''
		def rrbs = params.rrbs ? "--rrbs" : ''
		def cores = 1
		if(task.cpus){
			cores = (task.cpus as int) - 4
			if (params.single_end) cores = (task.cpus as int) - 3
			if (cores < 1) cores = 1
			if (cores > 4) cores = 4
		}
		if( params.single_end ) {
			"""
			trim_galore --fastqc --gzip $reads \
			  $rrbs $c_r1 $tpc_r1 --cores $cores
			"""
		} else {
			"""
			trim_galore --fastqc --gzip --paired $reads \
			  $rrbs $c_r1 $c_r2 $tpc_r1 $tpc_r2 --cores $cores
			"""
		}
	}
}

/*
 * STEP 3.1 - align with Bismark
 */
if( params.aligner =~ /bismark/ && !params.bams ){
	process bismark_align {
		tag "$name"
		publishDir "${params.outdir}/bismark_alignments", mode: 'copy',
			saveAs: {filename ->
				if( filename.indexOf(".fq.gz") > 0 ) "unmapped/$filename"
				else if( filename.indexOf("report.txt") > 0 ) "logs/$filename"
				else if( (!params.save_align_intermeds && !params.skip_deduplication && !params.rrbs).every() && filename == "where_are_my_files.txt" ) filename
				else if( (params.save_align_intermeds || params.skip_deduplication || params.rrbs).any() && filename != "where_are_my_files.txt" ) filename
				else null
			}

		input:
		set val(name), file(reads) from ch_trimmed_reads_for_alignment
		file index from ch_bismark_index_for_bismark_align.collect()
		file wherearemyfiles from ch_wherearemyfiles_for_bismark_align.collect()
		file knownsplices from ch_splicesites_for_bismark_hisat_align

		output:
		set val(name), file("*.bam") into ch_bam_for_bismark_deduplicate, ch_bam_for_bismark_summary, ch_bam_for_samtools_sort_index_flagstat
		set val(name), file("*report.txt") into ch_bismark_align_log_for_bismark_report, ch_bismark_align_log_for_bismark_summary, ch_bismark_align_log_for_multiqc
		file "*.fq.gz" optional true
		file "where_are_my_files.txt"

		script:
		// Paired-end or single end input files
		input = params.single_end ? reads : "-1 ${reads[0]} -2 ${reads[1]}"

		// Choice of read aligner
		aligner = params.aligner == "bismark_hisat" ? "--hisat2" : "--bowtie2"

		// Optional extra bismark parameters
		splicesites = params.aligner == "bismark_hisat" && knownsplices.name != 'null' ? "--known-splicesite-infile <(hisat2_extract_splice_sites.py ${knownsplices})" : ''
		pbat = params.pbat ? "--pbat" : ''
		non_directional = params.single_cell || params.zymo || params.non_directional ? "--non_directional" : ''
		unmapped = params.unmapped ? "--unmapped" : ''
		mismatches = params.relax_mismatches ? "--score_min L,0,-${params.num_mismatches}" : ''
		soft_clipping = params.local_alignment ? "--local" : ''

		// Try to assign sensible bismark memory units according to what the task was given
		multicore = ''
		if( task.cpus ){
			// Numbers based on recommendation by Felix for a typical mouse genome
			if( params.single_cell || params.zymo || params.non_directional ){
				cpu_per_multicore = 5
				mem_per_multicore = (18.GB).toBytes()
			} else {
				cpu_per_multicore = 3
				mem_per_multicore = (13.GB).toBytes()
			}
			// Check if the user has specified this and overwrite if so
			if(params.bismark_align_cpu_per_multicore) {
				cpu_per_multicore = (params.bismark_align_cpu_per_multicore as int)
			}
			if(params.bismark_align_mem_per_multicore) {
				mem_per_multicore = (params.bismark_align_mem_per_multicore as nextflow.util.MemoryUnit).toBytes()
			}
			// How many multicore splits can we afford with the cpus we have?
			ccore = ((task.cpus as int) / cpu_per_multicore) as int
			// Check that we have enough memory, assuming 13GB memory per instance (typical for mouse alignment)
			try {
				tmem = (task.memory as nextflow.util.MemoryUnit).toBytes()
				mcore = (tmem / mem_per_multicore) as int
				ccore = Math.min(ccore, mcore)
			} catch (all) {
				log.debug "Warning: Not able to define bismark align multicore based on available memory"
			}
			if( ccore > 1 ){
			  multicore = "--multicore $ccore"
			}
		}

		// Main command
		"""
		bismark $input \\
			$aligner \\
			--bam $pbat $non_directional $unmapped $mismatches $multicore \\
			--genome $index \\
			$reads \\
			$soft_clipping \\
			$splicesites
		"""
	}
	
/*
	 * STEP 4 - Samtools sort bismark
	 */
	process samtools_sort_index_flagstat_bismark {
		tag "$name"
		publishDir "${params.outdir}/samtools", mode: 'copy', 
			saveAs: {filename ->
				if(filename.indexOf("report.txt") > 0) "logs/$filename"
				else if( (!params.save_align_intermeds && !params.skip_deduplication && !params.rrbs).every() && filename == "where_are_my_files.txt") filename
				else if( (params.save_align_intermeds || params.skip_deduplication || params.rrbs).any() && filename != "where_are_my_files.txt") filename
				else null
			}

		input:
		set val(name), file(bam) from ch_bam_for_samtools_sort_index_flagstat
		file wherearemyfiles from ch_wherearemyfiles_for_bismark_samtools_sort.collect()

		output:
		set val(name), file("*.sorted.bam") into  ch_bam_for_preseq,ch_bam_sorted_for_picard
		file "where_are_my_files.txt"

		script:
		def avail_mem = task.memory ? ((task.memory.toGiga() - 6) / task.cpus).trunc() : false
		def sort_mem = avail_mem && avail_mem > 2 ? "-m ${avail_mem}G" : ''
		"""
		samtools sort $bam \\
			-@ ${task.cpus} $sort_mem \\
			-o ${bam.baseName}.sorted.bam
		
		samtools index ${bam.baseName}.sorted.bam
		samtools flagstat ${bam.baseName}.sorted.bam > ${bam.baseName}_flagstat_report.txt
		samtools stats ${bam.baseName}.sorted.bam > ${bam.baseName}_stats_report.txt
		"""
	}

	/*
	 * STEP 5 - Bismark deduplicate
	 */
	if( params.skip_deduplication || params.rrbs ) {
		ch_bam_for_bismark_deduplicate.into { ch_bam_dedup_for_bismark_methXtract; ch_dedup_bam_for_samtools_sort_index_flagstat }
		ch_bismark_dedup_log_for_bismark_report = Channel.from(false)
		ch_bismark_dedup_log_for_bismark_summary = Channel.from(false)
		ch_bismark_dedup_log_for_multiqc  = Channel.from(false)
	} else {
		process bismark_deduplicate {
			tag "$name"
			publishDir "${params.outdir}/bismark_deduplicated", mode: 'copy',
				saveAs: {filename -> filename.indexOf(".bam") == -1 ? "logs/$filename" : "$filename"}

			input:
			set val(name), file(bam) from ch_bam_for_bismark_deduplicate

			output:
			set val(name), file("*.deduplicated.bam") into ch_bam_dedup_for_bismark_methXtract, ch_dedup_bam_for_samtools_sort_index_flagstat
			set val(name), file("*.deduplication_report.txt") into ch_bismark_dedup_log_for_bismark_report, ch_bismark_dedup_log_for_bismark_summary, ch_bismark_dedup_log_for_multiqc

			script:
			fq_type = params.single_end ? '-s' : '-p'
			"""
			deduplicate_bismark $fq_type --bam $bam
			"""
		}
	}

	/*
	 * STEP 6 - Samtools sort bismark after dedup
	 */
	process samtools_sort_index_flagstat_dedup_bismark {
		tag "$name"
		publishDir "${params.outdir}/samtools", mode: 'copy', 
			saveAs: {filename ->
				if(filename.indexOf("report.txt") > 0) "logs/$filename"
				else if( (!params.save_align_intermeds && !params.skip_deduplication && !params.rrbs).every() && filename == "where_are_my_files.txt") filename
				else if( (params.save_align_intermeds || params.skip_deduplication || params.rrbs).any() && filename != "where_are_my_files.txt") filename
				else null
			}

		input:
		set val(name), file(bam) from ch_dedup_bam_for_samtools_sort_index_flagstat
		file wherearemyfiles from ch_wherearemyfiles_for_bismark_dedup_samtools_sort.collect()

		output:
		set val(name), file("*.sorted.bam") into ch_bam_dedup_for_qualimap 
		file "where_are_my_files.txt"

		script:
		def avail_mem = task.memory ? ((task.memory.toGiga() - 6) / task.cpus).trunc() : false
		def sort_mem = avail_mem && avail_mem > 2 ? "-m ${avail_mem}G" : ''
		"""
		samtools sort $bam \\
			-@ ${task.cpus} $sort_mem \\
			-o ${bam.baseName}.sorted.bam
		"""
	}
	
	/*
	 * STEP 6 - Bismark methylation extraction
	 */
	process bismark_methXtract {
		tag "$name"
		publishDir "${params.outdir}/bismark_methylation_calls", mode: 'copy',
			saveAs: {filename ->
				if( filename.indexOf("splitting_report.txt" ) > 0 ) "logs/$filename"
				else if( filename.indexOf("M-bias" ) > 0) "m-bias/$filename"
				else if( filename.indexOf(".cov" ) > 0 ) "methylation_coverage/$filename"
				else if( filename.indexOf("bedGraph" ) > 0 ) "bedGraph/$filename"
				else if( filename.indexOf("CpG_report" ) > 0 ) "stranded_CpG_report/$filename"
				else "methylation_calls/$filename"
			}

		input:
		set val(name), file(bam) from ch_bam_dedup_for_bismark_methXtract
		file index from ch_bismark_index_for_bismark_methXtract.collect()

		output:
		set val(name), file("*splitting_report.txt") into ch_bismark_splitting_report_for_bismark_report, ch_bismark_splitting_report_for_bismark_summary, ch_bismark_splitting_report_for_multiqc
		set val(name), file("*.M-bias.txt") into ch_bismark_mbias_for_bismark_report, ch_bismark_mbias_for_bismark_summary, ch_bismark_mbias_for_multiqc
		file '*.{png,gz}'

		script:
		comprehensive = params.comprehensive ? '--comprehensive --merge_non_CpG' : ''
		cytosine_report = params.cytosine_report ? "--cytosine_report --genome_folder ${index} " : ''
		meth_cutoff = params.meth_cutoff ? "--cutoff ${params.meth_cutoff}" : ''
		multicore = ''
		if( task.cpus ){
			// Numbers based on Bismark docs
			ccore = ((task.cpus as int) / 3) as int
			if( ccore > 1 ){
			  multicore = "--multicore $ccore"
			}
		}
		buffer = ''
		if( task.memory ){
			mbuffer = (task.memory as nextflow.util.MemoryUnit) - 2.GB
			// only set if we have more than 6GB available
			if( mbuffer.compareTo(4.GB) == 1 ){
			  buffer = "--buffer_size ${mbuffer.toGiga()}G"
			}
		}
		if(params.single_end) {
			"""
			bismark_methylation_extractor $comprehensive $meth_cutoff \\
				$multicore $buffer $cytosine_report \\
				--bedGraph \\
				--counts \\
				--gzip \\
				-s \\
				--report \\
				$bam
			"""
		} else {
			"""
			bismark_methylation_extractor $comprehensive $meth_cutoff \\
				$multicore $buffer $cytosine_report \\
				--ignore_r2 2 \\
				--ignore_3prime_r2 2 \\
				--bedGraph \\
				--counts \\
				--gzip \\
				-p \\
				--no_overlap \\
				--report \\
				$bam
			"""
		}
	}

	ch_bismark_align_log_for_bismark_report
	 .join(ch_bismark_dedup_log_for_bismark_report)
	 .join(ch_bismark_splitting_report_for_bismark_report)
	 .join(ch_bismark_mbias_for_bismark_report)
	 .set{ ch_bismark_logs_for_bismark_report }


	/*
	 * STEP 7 - Bismark Sample Report
	 */
	process bismark_report {
		tag "$name"
		publishDir "${params.outdir}/bismark_reports", mode: 'copy'

		input:
		set val(name), file(align_log), file(dedup_log), file(splitting_report), file(mbias) from ch_bismark_logs_for_bismark_report

		output:
		file '*{html,txt}' into ch_bismark_reports_results_for_multiqc

		script:
		"""
		bismark2report \\
			--alignment_report $align_log \\
			--dedup_report $dedup_log \\
			--splitting_report $splitting_report \\
			--mbias_report $mbias
		"""
	}

	/*
	 * STEP 8 - Bismark Summary Report
	 */
	process bismark_summary {
		publishDir "${params.outdir}/bismark_summary", mode: 'copy'

		input:
		file ('*') from ch_bam_for_bismark_summary.collect()
		file ('*') from ch_bismark_align_log_for_bismark_summary.collect()
		file ('*') from ch_bismark_dedup_log_for_bismark_summary.collect()
		file ('*') from ch_bismark_splitting_report_for_bismark_summary.collect()
		file ('*') from ch_bismark_mbias_for_bismark_summary.collect()

		output:
		file '*{html,txt}' into ch_bismark_summary_results_for_multiqc

		script:
		"""
		bismark2summary
		"""
	}
} // End of bismark processing block
else {
	ch_bismark_align_log_for_multiqc = Channel.from(false)
	ch_bismark_dedup_log_for_multiqc = Channel.from(false)
	ch_bismark_splitting_report_for_multiqc = Channel.from(false)
	ch_bismark_mbias_for_multiqc = Channel.from(false)
	ch_bismark_reports_results_for_multiqc = Channel.from(false)
	ch_bismark_summary_results_for_multiqc = Channel.from(false)
}


/*
 * Process with bwa-mem and assorted tools
 */
if( params.aligner == 'bwameth' && !params.bams ){
	process bwamem_align {
		tag "$name"
		publishDir "${params.outdir}/bwa-mem_alignments", mode: 'copy',
			saveAs: {filename ->
				if( !params.save_align_intermeds && filename == "where_are_my_files.txt" ) filename
				else if( params.save_align_intermeds && filename != "where_are_my_files.txt" ) filename
				else null
			}

		input:
		set val(name), file(reads) from ch_trimmed_reads_for_alignment
		file bwa_meth_indices from ch_bwa_meth_indices_for_bwamem_align.collect()
		file wherearemyfiles from ch_wherearemyfiles_for_bwamem_align.collect()

		output:
		set val(name), file('*.bam') into ch_bam_for_samtools_sort_index_flagstat
		file "where_are_my_files.txt"

		script:
		fasta = bwa_meth_indices[0].toString() - '.bwameth' - '.c2t' - '.amb' - '.ann' - '.bwt' - '.pac' - '.sa'
		prefix = reads[0].toString() - ~/(_R1)?(_trimmed)?(_val_1)?(\.fq)?(\.fastq)?(\.gz)?(\.bz2)?$/
		"""
		bwameth.py \\
			--threads ${task.cpus} \\
			--reference $fasta \\
			$reads | samtools view -bS - > ${prefix}.bam
		"""
	}


	/*
	 * STEP 4.- samtools flagstat on samples
	 */
	process samtools_sort_index_flagstat {
		tag "$name"
		publishDir "${params.outdir}/bwa-mem_alignments", mode: 'copy',
			saveAs: {filename ->
				if(filename.indexOf("report.txt") > 0) "logs/$filename"
				else if( (!params.save_align_intermeds && !params.skip_deduplication && !params.rrbs).every() && filename == "where_are_my_files.txt") filename
				else if( (params.save_align_intermeds || params.skip_deduplication || params.rrbs).any() && filename != "where_are_my_files.txt") filename
				else null
			}

		input:
		set val(name), file(bam) from ch_bam_for_samtools_sort_index_flagstat
		file wherearemyfiles from ch_wherearemyfiles_for_samtools_sort_index_flagstat.collect()

		output:
		set val(name), file("${bam.baseName}.sorted.bam") into ch_bam_sorted_for_markDuplicates, ch_bam_for_preseq, ch_bam_sorted_for_picard
		set val(name), file("${bam.baseName}.sorted.bam.bai") into ch_bam_index
		file "${bam.baseName}_flagstat_report.txt" into ch_flagstat_results_for_multiqc
		file "${bam.baseName}_stats_report.txt" into ch_samtools_stats_results_for_multiqc
		file "where_are_my_files.txt"

		script:
		def avail_mem = task.memory ? ((task.memory.toGiga() - 6) / task.cpus).trunc() : false
		def sort_mem = avail_mem && avail_mem > 2 ? "-m ${avail_mem}G" : ''
		"""
		samtools sort $bam \\
			-@ ${task.cpus} $sort_mem \\
			-o ${bam.baseName}.sorted.bam
		samtools index ${bam.baseName}.sorted.bam
		samtools flagstat ${bam.baseName}.sorted.bam > ${bam.baseName}_flagstat_report.txt
		samtools stats ${bam.baseName}.sorted.bam > ${bam.baseName}_stats_report.txt
		"""
	}

	/*
	 * STEP 5 - Mark duplicates
	 */
	if( params.skip_deduplication || params.rrbs ) {
		ch_bam_sorted_for_markDuplicates.into { ch_bam_dedup_for_methyldackel; ch_bam_dedup_for_qualimap }
		ch_bam_index.set { ch_bam_index_for_methyldackel }
		ch_markDups_results_for_multiqc = Channel.from(false)
	} else {
		process markDuplicates {
			tag "$name"
			publishDir "${params.outdir}/bwa-mem_markDuplicates", mode: 'copy',
				saveAs: {filename -> filename.indexOf(".bam") == -1 ? "logs/$filename" : "$filename"}

			input:
			set val(name), file(bam) from ch_bam_sorted_for_markDuplicates

			output:
			set val(name), file("${bam.baseName}.markDups.bam") into ch_bam_dedup_for_methyldackel, ch_bam_dedup_for_qualimap
			set val(name), file("${bam.baseName}.markDups.bam.bai") into ch_bam_index_for_methyldackel //ToDo check if this correctly overrides the original channel
			file "${bam.baseName}.markDups_metrics.txt" into ch_markDups_results_for_multiqc

			script:
			if( !task.memory ){
				log.info "[Picard MarkDuplicates] Available memory not known - defaulting to 3GB. Specify process memory requirements to change this."
				avail_mem = 3
			} else {
				avail_mem = task.memory.toGiga()
			}
			"""
			picard -Xmx${avail_mem}g MarkDuplicates \\
				INPUT=$bam \\
				OUTPUT=${bam.baseName}.markDups.bam \\
				METRICS_FILE=${bam.baseName}.markDups_metrics.txt \\
				REMOVE_DUPLICATES=false \\
				ASSUME_SORTED=true \\
				PROGRAM_RECORD_ID='null' \\
				VALIDATION_STRINGENCY=LENIENT
			samtools index ${bam.baseName}.markDups.bam
			"""
		}
	}

	/*
	 * STEP 6 - extract methylation with MethylDackel
	 */
	process methyldackel {
		tag "$name"
		publishDir "${params.outdir}/MethylDackel", mode: 'copy'

		input:
		set val(name),
			file(bam),
			file(bam_index),
			file(fasta),
			file(fasta_index) from ch_bam_dedup_for_methyldackel
			.join(ch_bam_index_for_methyldackel)
			.combine(ch_fasta_for_methyldackel)
			.combine(ch_fasta_index_for_methyldackel)

		output:
		file "${bam.baseName}*" into ch_methyldackel_results_for_multiqc

		script:
		all_contexts = params.comprehensive ? '--CHG --CHH' : ''
		min_depth = params.min_depth > 0 ? "--minDepth ${params.min_depth}" : ''
		ignore_flags = params.ignore_flags ? "--ignoreFlags" : ''
		methyl_kit = params.methyl_kit ? "--methylKit" : ''
		"""
		MethylDackel extract $all_contexts $ignore_flags $methyl_kit $min_depth $fasta $bam
		MethylDackel mbias $all_contexts $ignore_flags $fasta $bam ${bam.baseName} --txt > ${bam.baseName}_methyldackel.txt
		"""
	}

} // end of bwa-meth if block
else {
	ch_flagstat_results_for_multiqc = Channel.from(false)
	ch_samtools_stats_results_for_multiqc = Channel.from(false)
	ch_markDups_results_for_multiqc = Channel.from(false)
	ch_methyldackel_results_for_multiqc = Channel.from(false)
}




//////////////////////////////////////////////////////
/*
 * Process with BISCUIT and assorted tools (samblaster)
 */
if( params.aligner == 'biscuit' || params.bams ){
	if ( params.bams) {
		Channel
			.fromPath( params.bams )
			.ifEmpty { exit 1, "Cannot find any bam files matching: ${params.bams}\nNB: Path needs to be enclosed in quotes!" }
			.map { row -> [ row.simpleName, [ file(row, checkIfExists: true) ] ] }
			.into { ch_bam_for_samtools_stats; ch_bam_dedup_for_qualimap; ch_bam_for_preseq;ch_bam_sorted_for_pileup; ch_bam_sorted_for_epiread; ch_bam_noDups_for_QC; ch_bam_sorted_for_picard }
		 
		Channel 
			.fromPath( params.bams +".bai" )
			.map { row -> [ row.simpleName, [ file(row, checkIfExists: true) ] ] }
			.ifEmpty { exit 1, "Cannot find any bai files (bam-index) matching: ${params.bams}.bai\nNB: Path needs to be enclosed in quotes!" }
			.into { ch_bam_index_sorted_for_pileup; ch_bam_index_for_epiread; ch_bam_index_noDups_for_QC }
		
		process samtools_sort_index_flagstat_bams {
			tag "$name"
			publishDir "${params.outdir}", mode: 'copy',
				saveAs: {filename ->
					if(filename.indexOf("report.txt") > 0) "biscuit_alignments/logs/$filename"
					else if (filename.indexOf("sorted.bam") > 0) "biscuit_alignments/$filename"
					else if( (params.save_align_intermeds || params.skip_deduplication  || params.rrbs).any() && filename.indexOf("sorted.bam") > 0) "biscuit_alignments/$filename"
					else if( (!params.save_align_intermeds && !params.rrbs).every() && filename == "where_are_my_files.txt") filename
					else if( (params.save_align_intermeds || params.skip_deduplication  || params.rrbs).any() && filename != "where_are_my_files.txt") filename
					else null
				}

			input:
			set val(name), file(samblaster_bam) from ch_bam_for_samtools_stats
			file wherearemyfiles from ch_wherearemyfiles_for_samtools_sort_index_flagstat.collect()

			output:
			file "${name}_flagstat_report.txt" into ch_flagstat_results_biscuit_for_multiqc
			file "${name}_stats_report.txt" into ch_samtools_stats_results_biscuit_for_multiqc
			file "where_are_my_files.txt"
			
			script:
			def avail_mem = task.memory ? ((task.memory.toGiga() - 6) / task.cpus).trunc() : false
			def sort_mem = avail_mem && avail_mem > 2 ? "-m ${avail_mem}G" : ''
			"""
			samtools flagstat ${samblaster_bam} > ${name}_flagstat_report.txt
			samtools stats ${samblaster_bam} > ${name}_stats_report.txt
			"""
		}
		ch_markDups_results_for_multiqc = Channel.from(false)
		ch_samblaster_for_multiqc = Channel.from(false)
}
		
	else {
	process biscuit_align {
		tag "$name"
		publishDir "${params.outdir}/biscuit_alignments", mode: 'copy',
			saveAs: {filename ->
				if( !params.save_align_intermeds && filename == "where_are_my_files.txt" ) filename
				else if( params.save_align_intermeds && filename != "where_are_my_files.txt" ) filename
				else null
			}

		input:
		set val(name), file(reads) from ch_trimmed_reads_for_alignment
		file bwa_indices from ch_bwa_index_for_biscuit.collect()
		file wherearemyfiles from ch_wherearemyfiles_for_biscuit_align.collect()

		output:
		set val(name), file('*.bam') into ch_bam_for_markDuplicates //, ch_bam_for_samtools_sort_index_flagstat
		file "where_are_my_files.txt"

		script:
		fasta = bwa_indices[0].toString() - '.bwameth' - '.c2t' - '.amb' - '.ann' - '.bwt' - '.pac' - '.sa' - '.fai'  - '.par' - '.dau' -'.bis'
		assembly = fasta.replaceAll(/\.\w+/,"")
		prefix = reads[0].toString() - ~/(_R1)?(_trimmed)?(_val_1)?(\.fq)?(\.fastq)?(\.gz)?(\.bz2)?$/
		non_directional = params.non_directional ? ' -b 0' : ' -b 1'
		// Paired-end or single end input files and pbat or not: yes yes, yes no, no no
		input = params.pbat ? params.single_end ? reads + " -b 3" : "${reads[1]} ${reads[0]}" + non_directional :  reads + non_directional
		"""
		biscuit align -t ${task.cpus} $fasta $input | samtools view -Sb > ${name}.${assembly}.bam
		"""
	}

/*
* STEP 4 - Mark duplicates
*/
	if( params.skip_deduplication || params.rrbs ) {
		ch_bam_for_markDuplicates.set { ch_samblaster_for_samtools_sort_index_flagstat }
		ch_samblaster_for_multiqc = Channel.from(false)
	} else {
		process markDuplicates_samblaster {
			tag "$name"

			publishDir "${params.outdir}", mode: 'copy',
			saveAs: {filename ->
				if( filename.indexOf("log") > 0 ) "biscuit_markDuplicates/$filename"
				else null
			}

			input:
			set val(name), file(bam) from ch_bam_for_markDuplicates
			file wherearemyfiles from ch_wherearemyfiles_for_samblaster.collect()

			output:
			set val(name), file("${bam.baseName}.samblaster.bam") into ch_samblaster_for_samtools_sort_index_flagstat
			file "*log" into ch_samblaster_for_multiqc
			
			
			script:
			def avail_mem = task.memory ? ((task.memory.toGiga() - 6) / task.cpus).trunc() : false
			def sort_mem = avail_mem && avail_mem > 2 ? "-m ${avail_mem}G" : ''
			unmapped = params.single_end ? '--ignoreUnmated' : ''

			"""
			samtools sort -n $bam -@ ${task.cpus} $sort_mem| samtools view -h  | samblaster -M $unmapped -d "${bam.baseName}_discordant.sam" -s "${bam.baseName}_split.sam" -u "${bam.baseName}_.fastq" --excludeDups --addMateTags | samtools view -Sb > ${bam.baseName}.samblaster.bam 
			cp .command.log ${bam.baseName}.log
			"""
			}
		}

	/*
	 * STEP 5.- samtools flagstat on samples
	 */
	process samtools_sort_index_flagstat_biscuit {
		tag "$name_samblaster"
		publishDir "${params.outdir}", mode: 'copy',
			saveAs: {filename ->
				if(filename.indexOf("report.txt") > 0) "biscuit_alignments/logs/$filename"
				else if (filename.indexOf("sorted.bam") > 0) "biscuit_alignments/$filename"
				else if( (params.save_align_intermeds || params.skip_deduplication  || params.rrbs).any() && filename.indexOf("sorted.bam") > 0) "biscuit_alignments/$filename"
				else if( (!params.save_align_intermeds && !params.rrbs).every() && filename == "where_are_my_files.txt") filename
				else if( (params.save_align_intermeds || params.skip_deduplication  || params.rrbs).any() && filename != "where_are_my_files.txt") filename
				else null
			}

		input:
		//set val(name), file(bam) from ch_bam_for_samtools_sort_index_flagstat
		set val(name_samblaster), file(samblaster_bam) from ch_samblaster_for_samtools_sort_index_flagstat
		file wherearemyfiles from ch_wherearemyfiles_for_samtools_sort_index_flagstat.collect()

		output:
		set val(name_samblaster), file("*.sorted.bam") into ch_bam_dedup_for_qualimap,ch_bam_for_preseq,ch_bam_sorted_for_pileup, ch_bam_sorted_for_epiread, ch_bam_noDups_for_QC,ch_bam_sorted_for_picard
		//file "*.sorted.bam.bai" into ch_bam_index_sorted_for_pileup,ch_bam_index_for_epiread,ch_bam_index_noDups_for_QC
		set val(name_samblaster), file ("*.sorted.bam.bai") into ch_bam_index_sorted_for_pileup,ch_bam_index_for_epiread,ch_bam_index_noDups_for_QC
		file "${samblaster_bam.baseName}_flagstat_report.txt" into ch_flagstat_results_biscuit_for_multiqc
		file "${samblaster_bam.baseName}_stats_report.txt" into ch_samtools_stats_results_biscuit_for_multiqc
		file "where_are_my_files.txt"
		
		script:
		def avail_mem = task.memory ? ((task.memory.toGiga() - 6) / task.cpus).trunc() : false
		def sort_mem = avail_mem && avail_mem > 2 ? "-m ${avail_mem}G" : ''
		"""
		samtools sort $samblaster_bam \\
		-@ ${task.cpus} $sort_mem -l 9 \\
		-o ${samblaster_bam.baseName}.sorted.bam
		samtools index ${samblaster_bam.baseName}.sorted.bam

		samtools flagstat ${samblaster_bam.baseName}.sorted.bam > ${samblaster_bam.baseName}_flagstat_report.txt
		samtools stats ${samblaster_bam.baseName}.sorted.bam > ${samblaster_bam.baseName}_stats_report.txt
		"""
	}
}

	
	/*
	 * STEP 6 - Create vcf file with pileup, to extract methylation
	 */
	process createVCF {
		tag "$name"
		publishDir "${params.outdir}/methylation_extract", mode: 'copy',
		saveAs: {filename ->
			if( !params.save_pileup_file && filename == "where_are_my_files.txt") filename
			else if( filename.indexOf("vcf.gz") > 0 && params.save_pileup_file && filename != "where_are_my_files.txt") filename
			else null
		}

		input:
		set val(name), file(bam), file (bam_index) from ch_bam_sorted_for_pileup.join(ch_bam_index_sorted_for_pileup)
		file fasta from ch_fasta_for_pileup.collect()
		file fasta_index from ch_fasta_index_for_createVCF.collect()

		output:
		set val(name), file("${name}.vcf.gz*") into ch_vcf_biscuit_qc ,ch_vcf_for_bedgraph,ch_vcf_for_epiread
				 
	    script:
		filter_duplication = params.skip_deduplication || params.rrbs ? '-u' : ''
		"""
		biscuit pileup  -q ${task.cpus} $filter_duplication $fasta ${bam} -o ${name}.vcf 
		bgzip -@ ${task.cpus} -f ${name}.vcf
		tabix -f -p vcf ${name}.vcf.gz
		"""
	}  

	/*
	 * STEP 7 - create bedgraph file from vcf
	 */
	process createBedgraph {
		tag "$name"
		publishDir "${params.outdir}/methylation_extract", mode: 'copy'
			 
		input:
		set val(name), file(vcf) from ch_vcf_for_bedgraph

		output:
		set val(name), file("*bedgraph" ) into ch_bedgraph_for_intersect_soloWCGW

		script:
		min_depth = params.min_depth > 0 ? "${params.min_depth}" : '1'
		all_contexts = params.comprehensive ? 'c, cg, ch, hcg, gch' : 'cg'
		"""
		biscuit vcf2bed -k $min_depth -t $all_contexts  "${vcf[0]}" > "${name}.bedgraph"   
		"""
	}
	
	/***************
	*EXPERIMENTAL!!*
	***************/
	if (params.soloWCGW_file) {
		process intersect_soloWCGW {
			tag "$name"
			publishDir "${params.outdir}/methylation_extract", mode: 'copy'
	 
			input:
			set val(name), file(bedgraph) from ch_bedgraph_for_intersect_soloWCGW
			file soloWGCW from ch_soloWCGW_for_biscuitVCF.collect()

			output:
			file "*bedgraph" 
			script:
			"""
			bedtools intersect -wa -a "${bedgraph[0].baseName}.bedgraph"  -b $soloWGCW > ${name}_soloWCGW.bedgraph 
			"""
		}
	}
	
	if (params.epiread) {
		if (params.common_dbsnp) {
			process reformat_SNP {

				input:
				file commonSNP_file from ch_commonSNP_for_SNP.collect()
				
				output:
				file("reformattedSNP.snv.txt.gz*" ) into ch_reformattedSNP_for_SNP
					 
				script:
				"""
				less $commonSNP_file | $baseDir/bin/processUcscDbsnp.pl | grep snv | bgzip > reformattedSNP.snv.txt.gz
				tabix -s 1 -b 2 -e 3 reformattedSNP.snv.txt.gz
				"""
			}
		}
		else {
			ch_reformattedSNP_for_SNP = Channel.empty() 

		}

		
		 
		/***************************
		 THE PROCESS IS IN PROGRESS!
		****************************/
			process get_SNP_file { 
				tag "$name"
				publishDir "${params.outdir}/epireads/snp", mode: 'copy',
				saveAs: {filename ->
					if( filename.indexOf("bed") > 0 && params.save_snp_file && filename != "where_are_my_files.txt") filename
					else null
				}
				 
				input:
				set val(name), file(vcf) from ch_vcf_for_epiread
				file whitelist_file from ch_whitelist_for_SNP.collect()
				file reformatted_SNP from ch_reformattedSNP_for_SNP.collect().ifEmpty([])

				output:
				set val(name), file ("${name}.snp.bed") into ch_snp_for_epiread
					 // biscuit vcf2bed -t snp "${vcf[0]}" > "${name}.snp.bed"
				file "*gz"
			  
				script:
				whitelist = params.whitelist  ? "-R $whitelist_file" : ''
				snp_file = (reformatted_SNP.size()>0) ? "-a ${reformatted_SNP[0]}"  : '' 
				"""
				bcftools annotate $whitelist -O z ${snp_file} -h $projectDir/assets/common_dbsnp.hdr -c CHROM,FROM,TO,TYPE,COMMON_SOME,COMMON_ALL,REF_MIN,ALT_MIN,REF_DBSNP,ALT_DBSNP,REF_ALL,ALT_ALL,RSID,MAX_MAF "${vcf[0]}" > "${name}-whitelist-dbSNP.vcf.gz"
				tabix  -p vcf "${name}-whitelist-dbSNP.vcf.gz"
				bcftools view -O z -i'ALT!="N" & ALT!="." & ( (COUNT(GT=="0/1")>=1 & COMMON_ALL==1 & MAX_MAF>=0.05) | (COUNT(GT=="0/1" & GQ>=60)>=1) )' "${name}-whitelist-dbSNP.vcf.gz" > "${name}-whitelist-dbSNP-HET60.vcf.gz"
				tabix -p vcf "${name}-whitelist-dbSNP-HET60.vcf.gz"		
				bcftools query -u -i'GT="0/1" & GQ>=10' --format '%CHROM\t%POS\t%POS\t%REF\t%ALT[\t%GT\t%GQ\t%SP\t%AC\t%AF1]\t%RSID\t%COMMON_ALL\t%MAX_MAF\t%REF_MIN\t%ALT_MIN\n' "${name}-whitelist-dbSNP-HET60.vcf.gz" | awk -v OFS="\t" '{\$2 = \$2 - 1; print}' > "${name}.snp.bed"	 	
				"""
			}

		process epiread_convertion {
			   tag "$name"
            publishDir "${params.outdir}/epireads", mode: params.publish_dir_mode,
			saveAs: {filename ->
                if( params.debug_epiread && filename != "where_are_my_files.txt") filename
				else if( filename.indexOf("original") < 0 ) filename
                else null
            }

            input:
            set val(name),
            file(bam),
            file(bam_index),
            file(snp),
            file(fasta),
            file(fasta_index),
            file(whitelist) from ch_bam_sorted_for_epiread
                .join(ch_bam_index_for_epiread)
                .join(ch_snp_for_epiread)
                .combine(ch_fasta_for_epiread)
                .combine(ch_fasta_index_for_epiread)
                .combine(ch_whitelist_for_epiread)
            file (assets) from ch_assets_dir_with_cpg_for_epiread.collect()

            output:
            file "*${name}.e*.gz*"
            file "${name}.original.epiread.*" optional true

            script:
            snp_file = (snp.size()>0) ? "-B " + snp.toString() : ''
            cpg_file = assets.toString() + "/cpg.bed.gz"
            debug_merging_epiread = (params.debug_epiread_merging || params.debug_epiread) ? "debug" : ''
            no_filter_reverse = params.rrbs ? "-p" : ''
            if (params.single_end) {
                """
                bedtools intersect -abam $bam -b $whitelist -ubam -f 1.0 | samtools view  -Sb - > ${name}.bam
                samtools index ${name}.bam
                biscuit epiread -q ${task.cpus} $snp_file $no_filter_reverse $fasta ${name}.bam  |sort --parallel=${task.cpus} -T . -k1,1Vf -k5,5n | bgzip > ${name}.epiread.gz
                tabix -0 -s 1 -b 5 -e 5 ${name}.epiread.gz
                """
            } else {
                """
                zcat $cpg_file > cpg.bed

                bedtools intersect -abam $bam -b $whitelist -ubam -f 1.0 | samtools view  -Sb - > ${name}.bam
                samtools index ${name}.bam
                biscuit epiread -q ${task.cpus} $snp_file $fasta  ${name}.bam | sort --parallel=${task.cpus} -T .  -k2,2 -k1,1 -k4,4 -k3,3n > ${name}.original.epiread
                less ${name}.original.epiread | $projectDir/bin/epiread_pairedEnd_convertion "cpg.bed" $snp ${name}.epiread $debug_merging_epiread >  ${name}.err
                sort -k1,1Vf -k 2,2n -k 3,3n --parallel=${task.cpus} -T . ${name}.epiread | bgzip > ${name}.epiread.gz
                sort -k1,1Vf -k5,5n --parallel=${task.cpus} -T . ${name}.err | bgzip > ${name}.err.gz
                sort -k1,1Vf -k5,5n --parallel=${task.cpus} -T . ${name}.original.epiread | bgzip > ${name}.original.epiread.gz
                tabix -0 -s 1 -b 5 -e 5 ${name}.original.epiread.gz
                tabix -0 -p bed ${name}.epiread.gz
                tabix -0 -s 1 -b 5 -e 5 ${name}.err.gz
                """
			}
		}
	}

 if (params.assets_dir) {
	process biscuit_QC {
		tag "$name"
		publishDir "${params.outdir}/biscuit_QC", mode: 'copy'

		input:
		set val(name),
		file(vcf),
		file(bam),
		file(fasta),
		file(fasta_index),
		file(assets) from ch_vcf_biscuit_qc
		.join(ch_bam_noDups_for_QC)
		.combine(ch_fasta_for_biscuitQC)
		.combine(ch_fasta_index_for_biscuitQC)
		.combine(ch_assets_dir_for_biscuit_qc)
		
		//		$baseDir/bin/biscuit_QC.sh -v ${vcf[0]} -o ${name}.${assembly}_biscuitQC $assets $fasta ${name}.${assembly} ${bam} -p ${task.cpus}
		output:
		file "*_biscuitQC" into ch_QC_results_for_multiqc

		script:
		assembly = fasta.toString().replaceAll(/\.\w+/,"")
		"""
		$baseDir/bin/biscuit_QC.sh -v ${vcf[0]} -o ${name}.${assembly}_biscuitQC $assets $fasta ${name}.${assembly} ${bam} 				
		"""
	}
 } 
 else {
			ch_QC_results_for_multiqc = Channel.empty() 

		}

} // end of biscuit if block
else {
	ch_flagstat_results_biscuit_for_multiqc = Channel.from(false)
	ch_samtools_stats_results_biscuit_for_multiqc = Channel.from(false)
	ch_markDups_results_for_multiqc = Channel.from(false)
	ch_QC_results_for_multiqc = Channel.from(false)
	ch_samblaster_for_multiqc = Channel.from(false)
}

////////////////////////////////////////////////////////





/*
 * STEP 8 - Qualimap
 */
process qualimap {
	tag "$name"
	publishDir "${params.outdir}/qualimap", mode: 'copy'

	input:
	set val(name), file(bam) from ch_bam_dedup_for_qualimap

	output:
	file "${bam.baseName}_qualimap" into ch_qualimap_results_for_multiqc

	script:
	gcref = params.genome.toString().startsWith('GRCh') ? '-gd HUMAN' : ''
	gcref = params.genome.toString().startsWith('GRCm') ? '-gd MOUSE' : ''
	"""
	qualimap bamqc $gcref \\
		-bam ${bam.baseName}.bam \\
		-outdir ${bam.baseName}_qualimap \\
		--collect-overlap-pairs \\
		--java-mem-size=${task.memory.toGiga()}G \\
		-nt ${task.cpus} || true

	"""	
}

/*
 * STEP 9 - Picard - Preparation step
 */
process prepareGenomeToPicard {
	publishDir path: { params.save_reference ? "${params.outdir}/reference_genome" : params.outdir },
		saveAs: { (params.save_reference && it.indexOf("dict") >0) ? it : null }, mode: 'copy' 

	input:
	file fasta from ch_fasta_for_picard
	output:
	file "${fasta.baseName}.picard.fa" into ch_fasta_picard_for_picard
	file "${fasta.baseName}.picard.dict" into ch_fasta_picard_dict_for_picard


	script:
	if( !task.memory ){
		log.info "[Picard MarkDuplicates] Available memory not known - defaulting to 3GB. Specify process memory requirements to change this."
		avail_mem = 3
	} else {
		avail_mem = task.memory.toGiga()
	}	 
	"""
	mv ${fasta}  ${fasta.baseName}.picard.fa
	picard -Xmx${avail_mem}g  CreateSequenceDictionary \\
	R=${fasta.baseName}.picard.fa \\
	O=${fasta.baseName}.picard.dict
	"""
}

/*
 * STEP 10 - Picard InsertSizeMetrics and GcBiasMetrics
 */
process picardMetrics {
	tag "$name"
	publishDir "${params.outdir}/picardMetrics", mode: 'copy',
		 saveAs: { filename ->
				  if (filename.indexOf(".txt") > 0) filename
				  else if (filename.indexOf(".pdf") > 0) "pdf/$filename"
				  else null
			}
	input:
	set val(name), file(bam) from ch_bam_sorted_for_picard
	file fasta from ch_fasta_picard_for_picard.collect()
	file dict from ch_fasta_picard_dict_for_picard.collect()

	output:
	file "${name}.*.pdf"  
	file "${name}.*.txt" into ch_picard_results_for_multiqc
	
	script:
	if( !task.memory ){
		log.info "[Picard MarkDuplicates] Available memory not known - defaulting to 3GB. Specify process memory requirements to change this."
		avail_mem = 3
	} else {
		avail_mem = task.memory.toGiga()
	}
	"""
	picard -Xmx${avail_mem}g CollectInsertSizeMetrics \\
	INPUT=$bam \\
	OUTPUT=${name}.insert_size_metrics.txt \\
	HISTOGRAM_FILE=${name}.insert_size_histogram.pdf \\
	ASSUME_SORTED=true \\
	VALIDATION_STRINGENCY=LENIENT
		set +e 


	picard -Xmx${avail_mem}g CollectGcBiasMetrics \\
	INPUT=$bam \\
	OUTPUT=${name}.gc_bias_metrics.txt \\
	CHART=${name}.gc_bias_metrics.pdf \\
	SUMMARY_OUTPUT=${name}.summary_metrics.txt \\
	ASSUME_SORTED=true \\
	IS_BISULFITE_SEQUENCED=true \\
	REFERENCE_SEQUENCE=$fasta \\
	VALIDATION_STRINGENCY=LENIENT 

	[ ! "\$?" -eq "0" ] && picard -Xmx${avail_mem}g ReorderSam I=$bam O=${bam.baseName}.picard.bam SEQUENCE_DICTIONARY=$fasta VALIDATION_STRINGENCY=LENIENT TMP_DIR=. && picard -Xmx${avail_mem}g CollectGcBiasMetrics \\
	INPUT=${bam.baseName}.picard.bam  \\
	OUTPUT=${name}.gc_bias_metrics.txt \\
	CHART=${name}.gc_bias_metrics.pdf \\
	SUMMARY_OUTPUT=${name}.summary_metrics.txt \\
	ASSUME_SORTED=true \\
	IS_BISULFITE_SEQUENCED=true \\
	REFERENCE_SEQUENCE=$fasta \\
	VALIDATION_STRINGENCY=LENIENT
	echo "fine"
	"""
}

/*
 * STEP 11 - preseq
 */
process preseq {
	tag "$name"
	publishDir "${params.outdir}/preseq", mode: 'copy'

	input:
	set val(name), file(bam) from ch_bam_for_preseq

	output:
	file "${bam.baseName}.ccurve.txt" into preseq_results

	script:
	"""
	preseq lc_extrap -v -B ${bam.baseName}.bam -o ${bam.baseName}.ccurve.txt
	"""
}

/*
 * STEP 12 - MultiQC
 */
process multiqc {
	publishDir "${params.outdir}/MultiQC", mode: 'copy'

	input:
	file (multiqc_config) from ch_multiqc_config
	file (mqc_custom_config) from ch_multiqc_custom_config.collect().ifEmpty([])
	file ('fastqc/*') from ch_fastqc_results_for_multiqc.collect().ifEmpty([])
	file ('trimgalore/*') from ch_trim_galore_results_for_multiqc.collect().ifEmpty([])
	file ('bismark/*') from ch_bismark_align_log_for_multiqc.collect().ifEmpty([])
	file ('bismark/*') from ch_bismark_dedup_log_for_multiqc.collect().ifEmpty([])
	file ('bismark/*') from ch_bismark_splitting_report_for_multiqc.collect().ifEmpty([])
	file ('bismark/*') from ch_bismark_mbias_for_multiqc.collect().ifEmpty([])
	file ('bismark/*') from ch_bismark_reports_results_for_multiqc.collect().ifEmpty([])
	file ('bismark/*') from ch_bismark_summary_results_for_multiqc.collect().ifEmpty([])
	file ('samtools/*') from ch_flagstat_results_for_multiqc.flatten().collect().ifEmpty([])
	file ('samtools/*') from ch_samtools_stats_results_for_multiqc.flatten().collect().ifEmpty([])
	file ('samtools/*') from ch_flagstat_results_biscuit_for_multiqc.flatten().collect().ifEmpty([])
	file ('samtools/*') from ch_samtools_stats_results_biscuit_for_multiqc.flatten().collect().ifEmpty([])
	file ('bwa-mem_markDuplicates/*') from ch_markDups_results_for_multiqc.flatten().collect().ifEmpty([])
	file ('methyldackel/*') from ch_methyldackel_results_for_multiqc.flatten().collect().ifEmpty([])
	file ('qualimap/*') from ch_qualimap_results_for_multiqc.collect().ifEmpty([])
	file ('preseq/*') from preseq_results.collect().ifEmpty([])
	file ('biscuit_QC/*') from ch_QC_results_for_multiqc.collect().ifEmpty([])
	file ('biscuit_markDuplicates/*') from ch_samblaster_for_multiqc.collect().ifEmpty([])
	file ('picardMetrics/*') from ch_picard_results_for_multiqc.collect().ifEmpty([])
	file ('software_versions/*') from ch_software_versions_yaml_for_multiqc.collect()
	file workflow_summary from ch_workflow_summary.collectFile(name: "workflow_summary_mqc.yaml")
	//file workflow_summary from create_workflow_summary(summary)

	output:
	file "*multiqc_report.html" into ch_multiqc_report
	file "*_data"
	//file "multiqc_plots"
	file "*_plots"

	script:
	rtitle = custom_runName ? "--title \"$custom_runName\"" : ''
	rfilename = custom_runName ? "--filename " + custom_runName.replaceAll('\\W','_').replaceAll('_+','_') + "_multiqc_report" : ''
	custom_config_file = params.multiqc_config ? "--config $mqc_custom_config" : '' //"--config $multiqc_config"
	"""
	multiqc -f $rtitle $rfilename $custom_config_file . \\
		-m custom_content -m picard -m qualimap -m bismark -m samtools -m preseq -m cutadapt -m fastqc -m biscuit -m samblaster
	"""
}
 
/*
 * STEP 13 - Output Description HTML
 */
process output_documentation {
	publishDir "${params.outdir}/pipeline_info", mode: 'copy'

	input:
	file output_docs from ch_output_docs

	output:
	file "results_description.html"

	script:
	"""
	markdown_to_html.py $output_docs -o results_description.html
	"""
}

/*
 * Completion e-mail notification
 */
workflow.onComplete {

	// Set up the e-mail variables
	def subject = "[nf-core/methylseq] Successful: $workflow.runName"
	if (!workflow.success) {
		subject = "[nf-core/methylseq] FAILED: $workflow.runName"
	}
	def email_fields = [:]
	email_fields['version'] = workflow.manifest.version
	email_fields['runName'] = custom_runName ?: workflow.runName
	email_fields['success'] = workflow.success
	email_fields['dateComplete'] = workflow.complete
	email_fields['duration'] = workflow.duration
	email_fields['exitStatus'] = workflow.exitStatus
	email_fields['errorMessage'] = (workflow.errorMessage ?: 'None')
	email_fields['errorReport'] = (workflow.errorReport ?: 'None')
	email_fields['commandLine'] = workflow.commandLine
	email_fields['projectDir'] = workflow.projectDir
	email_fields['summary'] = summary
	email_fields['summary']['Date Started'] = workflow.start
	email_fields['summary']['Date Completed'] = workflow.complete
	email_fields['summary']['Pipeline script file path'] = workflow.scriptFile
	email_fields['summary']['Pipeline script hash ID'] = workflow.scriptId
	if (workflow.repository) email_fields['summary']['Pipeline repository Git URL'] = workflow.repository
	if (workflow.commitId) email_fields['summary']['Pipeline repository Git Commit'] = workflow.commitId
	if (workflow.revision) email_fields['summary']['Pipeline Git branch/tag'] = workflow.revision
	email_fields['summary']['Nextflow Version'] = workflow.nextflow.version
	email_fields['summary']['Nextflow Build'] = workflow.nextflow.build
	email_fields['summary']['Nextflow Compile Timestamp'] = workflow.nextflow.timestamp

	// On success try attach the multiqc report
	def mqc_report = null
	try {
		if (workflow.success) {
			mqc_report = ch_multiqc_report.getVal()
			if (mqc_report.getClass() == ArrayList) {
				log.warn "[nf-core/methylseq] Found multiple reports from process 'multiqc', will use only one"
				mqc_report = mqc_report[0]
				}
		}
	} catch (all) {
		log.warn "[nfcore/methylseq] Could not attach MultiQC report to summary email"
	}

	// Check if we are only sending emails on failure
	email_address = params.email
	if (!params.email && params.email_on_fail && !workflow.success) {
		email_address = params.email_on_fail
	}

	// Render the TXT template
	def engine = new groovy.text.GStringTemplateEngine()
	def tf = new File("$baseDir/assets/email_template.txt")
	def txt_template = engine.createTemplate(tf).make(email_fields)
	def email_txt = txt_template.toString()

	// Render the HTML template
	def hf = new File("$baseDir/assets/email_template.html")
	def html_template = engine.createTemplate(hf).make(email_fields)
	def email_html = html_template.toString()

	// Render the sendmail template
	def smail_fields = [ email: email_address, subject: subject, email_txt: email_txt, email_html: email_html, baseDir: "$baseDir", mqcFile: mqc_report, mqcMaxSize: params.max_multiqc_email_size.toBytes() ]
	def sf = new File("$baseDir/assets/sendmail_template.txt")
	def sendmail_template = engine.createTemplate(sf).make(smail_fields)
	def sendmail_html = sendmail_template.toString()

	// Send the HTML e-mail
	if (email_address) {
		try {
			if (params.plaintext_email) { throw GroovyException('Send plaintext e-mail, not HTML') }
			// Try to send HTML e-mail using sendmail
			[ 'sendmail', '-t' ].execute() << sendmail_html
			log.info "[nf-core/methylseq] Sent summary e-mail to $email_address (sendmail)"
		} catch (all) {
			// Catch failures and try with plaintext
			[ 'mail', '-s', subject, email_address ].execute() << email_txt
			log.info "[nf-core/methylseq] Sent summary e-mail to $email_address (mail)"
		}
	}

	// Write summary e-mail HTML to a file
	def output_d = new File("${params.outdir}/pipeline_info/")
	if (!output_d.exists()) {
		output_d.mkdirs()
	}
	def output_hf = new File(output_d, "pipeline_report.html")
	output_hf.withWriter { w -> w << email_html }
	def output_tf = new File(output_d, "pipeline_report.txt")
	output_tf.withWriter { w -> w << email_txt }

	c_green = params.monochrome_logs ? '' : "\033[0;32m";
	c_purple = params.monochrome_logs ? '' : "\033[0;35m";
	c_red = params.monochrome_logs ? '' : "\033[0;31m";
	c_reset = params.monochrome_logs ? '' : "\033[0m";

	if (workflow.stats.ignoredCount > 0 && workflow.success) {
		log.info "-${c_purple}Warning, pipeline completed, but with errored process(es) ${c_reset}-"
		log.info "-${c_red}Number of ignored errored process(es) : ${workflow.stats.ignoredCount} ${c_reset}-"
		log.info "-${c_green}Number of successfully ran process(es) : ${workflow.stats.succeedCount} ${c_reset}-"
	}

	if (workflow.success) {
		log.info "-${c_purple}[nf-core/methylseq]${c_green} Pipeline completed successfully${c_reset}-"
	} else {
		checkHostname()
		log.info "-${c_purple}[nf-core/methylseq]${c_red} Pipeline completed with errors${c_reset}-"
	}
}

def nfcoreHeader() {
	// Log colors ANSI codes
	c_black = params.monochrome_logs ? '' : "\033[0;30m";
	c_blue = params.monochrome_logs ? '' : "\033[0;34m";
	c_cyan = params.monochrome_logs ? '' : "\033[0;36m";
	c_dim = params.monochrome_logs ? '' : "\033[2m";
	c_green = params.monochrome_logs ? '' : "\033[0;32m";
	c_purple = params.monochrome_logs ? '' : "\033[0;35m";
	c_reset = params.monochrome_logs ? '' : "\033[0m";
	c_white = params.monochrome_logs ? '' : "\033[0;37m";
	c_yellow = params.monochrome_logs ? '' : "\033[0;33m";

	return """    -${c_dim}--------------------------------------------------${c_reset}-
											${c_green},--.${c_black}/${c_green},-.${c_reset}
	${c_blue}        ___     __   __   __   ___     ${c_green}/,-._.--~\'${c_reset}
	${c_blue}  |\\ | |__  __ /  ` /  \\ |__) |__         ${c_yellow}}  {${c_reset}
	${c_blue}  | \\| |       \\__, \\__/ |  \\ |___     ${c_green}\\`-._,-`-,${c_reset}
											${c_green}`._,._,\'${c_reset}
	${c_purple}  nf-core/methylseq v${workflow.manifest.version}${c_reset}
	-${c_dim}--------------------------------------------------${c_reset}-
	""".stripIndent()
}

def checkHostname() {
	def c_reset = params.monochrome_logs ? '' : "\033[0m"
	def c_white = params.monochrome_logs ? '' : "\033[0;37m"
	def c_red = params.monochrome_logs ? '' : "\033[1;91m"
	def c_yellow_bold = params.monochrome_logs ? '' : "\033[1;93m"
	if (params.hostnames) {
		def hostname = "hostname".execute().text.trim()
		params.hostnames.each { prof, hnames ->
			hnames.each { hname ->
				if (hostname.contains(hname) && !workflow.profile.contains(prof)) {
					log.error "====================================================\n" +
							"  ${c_red}WARNING!${c_reset} You are running with `-profile $workflow.profile`\n" +
							"  but your machine hostname is ${c_white}'$hostname'${c_reset}\n" +
							"  ${c_yellow_bold}It's highly recommended that you use `-profile $prof${c_reset}`\n" +
							"============================================================"
				}
			}
		}
	}
}
