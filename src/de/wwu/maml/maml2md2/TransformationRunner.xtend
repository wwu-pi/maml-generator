package de.wwu.maml.maml2md2

import de.wwu.maml.dsl.maml.MamlFactory
import de.wwu.maml.dsl.maml.MamlPackage
import de.wwu.maml.dsl.maml.UseCase
import de.wwu.maml.dsl.mamldata.MamldataPackage
import de.wwu.maml.dsl.mamlgui.MamlguiPackage
import de.wwu.maml.maml2md2.rules.Maml2md2Transformation
import de.wwu.md2.framework.MD2StandaloneSetup
import de.wwu.md2.framework.mD2.Controller
import de.wwu.md2.framework.mD2.MD2Model
import de.wwu.md2.framework.mD2.MD2Package
import de.wwu.md2.framework.mD2.Model
import de.wwu.md2.framework.mD2.View
import de.wwu.md2.framework.mD2.Workflow
import java.io.IOException
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.emf.ecore.xmi.impl.EcoreResourceFactoryImpl
import org.eclipse.emf.mwe.utils.StandaloneSetup

import static extension de.wwu.maml.maml2md2.util.ResourceHelper.*
import de.wwu.maml.maml2md2.correspondence.maml2md2.Corr

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
//		runner.transformMAMLtoMD2()
		runner.transformMD2toMAML()
//		runner.saveModels("test")
	}
	
	/**
	 * Initiates a synchronization between a source and a target model. The BXtend Transformation is
	 * initialized and empty source, target and correspondence models are created.
	 * Finally a FamilyRegister is added to the source model and an initial forward transformation is issued
	 * to create a corresponding PersonRegister.
	 */
	def transformMAMLtoMD2() {
		TransformationRunner.initEMFRegistration()

		println("Start transformation: MAML -> MD2")
		
		// Define the common MD2Root element
		source.createResource(URI.createURI("sourceModel.maml"));
		val mamlRoot = MamlFactory.eINSTANCE.createModel();
		source.resources.get(0).getContents().add(mamlRoot);
		
		// Define the transformation input
		// TODO crawl folders to find all .maml files
		val modelSources = newArrayList(); // List of MAML use cases
		modelSources.add(URI.createURI(RESULTPATH + "/WHO5.maml"));

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
	}
	
	def transformMD2toMAML(){
		TransformationRunner.initEMFRegistration()

		println("Start transformation: MD2 -> MAML")
				
		source.createResource(URI.createURI("sourceModel.maml"));
		corr = new ResourceSetImpl().createResource(URI.createURI("corrModel.corr"));
		
		//Load MD2
		target.getResource(URI.createURI(RESULTPATH + "/testMD2Model.xmi"), true)
		target.getResource(URI.createURI(RESULTPATH + "/testMD2View.xmi"), true)
				
		val maml2md2 = new Maml2md2Transformation(source, target, corr);
		maml2md2.targetToSource()
	}
	
	def static void initEMFRegistration() {
		MD2StandaloneSetup.doSetup //createInjectorAndDoEMFRegistration();
		//XtextResourceSet resourceSet = injector.getInstance(XtextResourceSet);
		
		// Register Xtext Resource Factory
		new StandaloneSetup().setPlatformUri("../");

		// Register MAML and MD2 meta models
		if (!EPackage.Registry.INSTANCE.containsKey("http://de/wwu/maml/dsl/maml")) {
			EPackage.Registry.INSTANCE.put("http://de/wwu/maml/dsl/maml", MamlPackage.eINSTANCE);
		}
		if (!EPackage.Registry.INSTANCE.containsKey("http://de/wwu/maml/dsl/mamldata")) {
			EPackage.Registry.INSTANCE.put("http://de/wwu/maml/dsl/mamldata", MamldataPackage.eINSTANCE);
		}
		if (!EPackage.Registry.INSTANCE.containsKey("http://de/wwu/maml/dsl/mamlgui")) {
			EPackage.Registry.INSTANCE.put("http://de/wwu/maml/dsl/mamlgui", MamlguiPackage.eINSTANCE);
		}
		if (!EPackage.Registry.INSTANCE.containsKey("http://www.wwu.de/md2/framework/MD2")) {
			EPackage.Registry.INSTANCE.put("http://www.wwu.de/md2/framework/MD2", MD2Package.eINSTANCE);
		}	
	}
	
	/**
	 * Allows to save the current state of the source and target models
	 * 
	 * @param name : Filename 
	 */
	def void saveModels(String name) {
		val set = new ResourceSetImpl();
		set.getResourceFactoryRegistry().getExtensionToFactoryMap().put(Resource.Factory.Registry.DEFAULT_EXTENSION, new EcoreResourceFactoryImpl());
		
		val srcURI = URI.createFileURI(RESULTPATH + "/" + name + "MAML.xmi");
		val trgURIM = URI.createFileURI(RESULTPATH + "/" + name + "MD2Model.xmi"); // Todo serialize as MD2 models
		val trgURIV = URI.createFileURI(RESULTPATH + "/" + name + "MD2View.xmi");
		val trgURIC = URI.createFileURI(RESULTPATH + "/" + name + "MD2Controller.xmi");
		val trgURIW = URI.createFileURI(RESULTPATH + "/" + name + "MD2Workflow.xmi");
		
		val resSource = set.createResource(srcURI);
		val resTargetM = set.createResource(trgURIM);
		val resTargetV = set.createResource(trgURIV);
		val resTargetC = set.createResource(trgURIC);
		val resTargetW = set.createResource(trgURIW);
		
		resSource.getContents().add(EcoreUtil.copy(source.getMAMLResource.contents.get(0)));
		resTargetM.getContents().add(EcoreUtil.copy(target.MD2ModelResource.contents.filter[it instanceof MD2Model && (it as MD2Model).modelLayer instanceof Model]?.get(0)));
		resTargetV.getContents().add(EcoreUtil.copy(target.MD2ViewResource.contents.filter[it instanceof MD2Model && (it as MD2Model).modelLayer instanceof View]?.get(0)));
		resTargetC.getContents().add(EcoreUtil.copy(target.MD2ControllerResource.contents.filter[it instanceof MD2Model && (it as MD2Model).modelLayer instanceof Controller]?.get(0)));
		resTargetW.getContents().add(EcoreUtil.copy(target.MD2WorkflowResource.contents.filter[it instanceof MD2Model && (it as MD2Model).modelLayer instanceof Workflow]?.get(0)));
		
		try {
			resTargetM.save(null);
			resTargetV.save(null);
			resTargetC.save(null);
			resTargetW.save(null);
		} catch (IOException e) {
			e.printStackTrace();
		}			
	}
}