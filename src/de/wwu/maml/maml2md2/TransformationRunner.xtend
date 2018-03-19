package de.wwu.maml.maml2md2

import de.wwu.maml.dsl.maml.MamlFactory
import de.wwu.maml.dsl.maml.UseCase
import de.wwu.maml.maml2md2.rules.Maml2md2Transformation
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.util.EcoreUtil

import static extension de.wwu.maml.maml2md2.util.ResourceHelper.*

class TransformationRunner {
	
	private ResourceSet source = new ResourceSetImpl();
	private ResourceSet target = new ResourceSetImpl();
	private Resource corr;
	
	private static final String RESULTPATH = "results/BXtend";
	
	/**
	 * Main program
	 */	
	def static void main(String[] args){
		val runner = new TransformationRunner()
		runner.transformMAMLtoMD2()
//		runner.transformMD2toMAML()
	}
	
	/**
	 * Initiates a synchronization between a source and a target model. The BXtend Transformation is
	 * initialized and empty source, target and correspondence models are created.
	 * Finally a FamilyRegister is added to the source model and an initial forward transformation is issued
	 * to create a corresponding PersonRegister.
	 */
	def transformMAMLtoMD2() {
		XmiToMd2Converter.init()

		println("Start transformation: MAML -> MD2")
		
		// Define the common MD2Root element
		source.createResource(URI.createURI("sourceModel.maml"));
		val mamlRoot = MamlFactory.eINSTANCE.createModel();
		source.resources.get(0).getContents().add(mamlRoot);
		
		// Define the transformation input
		// TODO crawl folders to find all .maml files
		val modelSources = newArrayList(); // List of MAML use cases
		val inputUri = URI.createURI(RESULTPATH + "/WHO5.maml")
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
		target.createResource(URI.createURI("targetModel.md2"));
		target.createResource(URI.createURI("targetView.md2"));
		target.createResource(URI.createURI("targetController.md2"));
		target.createResource(URI.createURI("targetWorkflow.md2"));
		corr = new ResourceSetImpl().createResource(URI.createURI("corrModel.corr"));
		
		val maml2md2 = new Maml2md2Transformation(source, target, corr);
		maml2md2.sourceToTarget()
		
		// Save MD2 models
		val inputFileName = inputUri.lastSegment.substring(0, inputUri.lastSegment.lastIndexOf('.'))
		val targetFileM = RESULTPATH + "/" + inputFileName + "MD2Model.md2"
		val targetFileV = RESULTPATH + "/" + inputFileName + "MD2View.md2"
		val targetFileC = RESULTPATH + "/" + inputFileName + "MD2Controller.md2"
		val targetFileW = RESULTPATH + "/" + inputFileName + "MD2Workflow.md2"
		
		try {
			XmiToMd2Converter.XmiToMd2(target.MD2ModelResource, targetFileM)
		} catch (Exception e){ e.printStackTrace() }
		try {
			XmiToMd2Converter.XmiToMd2(target.MD2ViewResource, targetFileV)
		} catch (Exception e){ e.printStackTrace() }
		try {
			XmiToMd2Converter.XmiToMd2(target.MD2ControllerResource, targetFileC)
		} catch (Exception e){ e.printStackTrace() }
		try {
			XmiToMd2Converter.XmiToMd2(target.MD2WorkflowResource, targetFileW)
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