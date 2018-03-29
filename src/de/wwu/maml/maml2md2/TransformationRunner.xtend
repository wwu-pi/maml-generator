package de.wwu.maml.maml2md2

import de.wwu.maml.dsl.maml.MamlFactory
import de.wwu.maml.dsl.maml.UseCase
import de.wwu.maml.maml2md2.rules.Maml2md2Transformation
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.util.EcoreUtil

class TransformationRunner {
	
	private ResourceSet source = new ResourceSetImpl();
	private ResourceSet target = new ResourceSetImpl();
	private Resource corr;
	
	private static final String RESULTPATH = "results/BXtend";
	
	/**
	 * Main program
	 */	
	def static void main(String[] args){
		val fileName = "WHO5" // "VisualAcuity"
		val runner = new TransformationRunner()
		runner.transformMAMLtoMD2(fileName)
//		runner.transformMD2toMAML()
	}
	
	/**
	 * Initiates a synchronization between a source and a target model. The BXtend Transformation is
	 * initialized and empty source, target and correspondence models are created.
	 * Finally a FamilyRegister is added to the source model and an initial forward transformation is issued
	 * to create a corresponding PersonRegister.
	 */
	def transformMAMLtoMD2(String filename) {
		XmiToMd2Converter.init()

		println("Start transformation: MAML -> MD2")
		
		// Define the common MD2Root element
		source.createResource(URI.createURI("sourceModel.maml"));
		val mamlRoot = MamlFactory.eINSTANCE.createModel();
		source.resources.get(0).getContents().add(mamlRoot);
		
		// Define the transformation input
		// TODO crawl folders to find all .maml files
		val modelSources = newArrayList(); // List of MAML use cases
		val inputUri = URI.createURI(RESULTPATH + "/" + filename + ".maml")
		mamlRoot.projectName = filename
		modelSources.add(inputUri);

		for (URI modelSource : modelSources) {
			val inResource = new ResourceSetImpl().getResource(modelSource, true);
			// Add use cases to common model root
			if (inResource.getContents() === null || inResource.getContents().size() == 0) {
				System.out.println("No content in model: " + modelSource.toPlatformString(true));
			} else {
				val useCaseRoot = EcoreUtil.getRootContainer(inResource.getContents().get(0));
				if (useCaseRoot instanceof UseCase) {
					mamlRoot.getUseCases().add(useCaseRoot);
				}
			}
		}
		
		// Create empty resources for target and correlation models 
		val md2Resource = target.createResource(URI.createURI("fullModel.md2"));
		corr = new ResourceSetImpl().createResource(URI.createURI("corrModel.corr"));
		
		val maml2md2 = new Maml2md2Transformation(source, target, corr);
		maml2md2.sourceToTarget()
		
		// Save MD2 models
		try {
			val targetPath = RESULTPATH + "/" + mamlRoot.projectName + "/"
		
			XmiToMd2Converter.XmiToMd2(md2Resource, targetPath, mamlRoot.projectName)
			println("Done. Generated MD2 output saved to " + targetPath)
		} catch (Exception e){ e.printStackTrace() }
	}
	
	def transformMD2toMAML(){
		//TransformationRunner.initEMFRegistration()

		println("Start transformation: MD2 -> MAML")
				
		source.createResource(URI.createURI("sourceModel.maml"));
		corr = new ResourceSetImpl().createResource(URI.createURI("corrModel.corr"));
		
		//Load MD2
		target.getResource(URI.createURI(RESULTPATH + "/testMD2Model.xmi"), true)
		target.getResource(URI.createURI(RESULTPATH + "/testMD2View.xmi"), true)
				
		val maml2md2 = new Maml2md2Transformation(source, target, corr);
		maml2md2.targetToSource()
	}
}