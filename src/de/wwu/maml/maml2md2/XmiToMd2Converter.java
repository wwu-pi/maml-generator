package de.wwu.maml.maml2md2;

import java.io.IOException;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.emf.ecore.xmi.XMLResource;
import org.eclipse.xtext.EcoreUtil2;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.resource.XtextResourceSet;
import org.eclipse.xtext.util.CancelIndicator;
import org.eclipse.xtext.validation.CheckMode;
import org.eclipse.xtext.validation.IResourceValidator;
import org.eclipse.xtext.validation.Issue;

import com.google.inject.Injector;

import de.wwu.maml.maml2md2.util.ResourceHelper;
import de.wwu.md2.framework.MD2StandaloneSetup;
import de.wwu.md2.framework.mD2.MD2Package;

public class XmiToMd2Converter {

	public static void init() {
		// Register Xtext Resource Factory
		new org.eclipse.emf.mwe.utils.StandaloneSetup().setPlatformUri("../");

		// Register MAML and MD2 meta models
		if (!EPackage.Registry.INSTANCE.containsKey("http://de/wwu/maml/dsl/maml")) {
			EPackage.Registry.INSTANCE.put("http://de/wwu/maml/dsl/maml", de.wwu.maml.dsl.maml.MamlPackage.eINSTANCE);
		}
		if (!EPackage.Registry.INSTANCE.containsKey("http://de/wwu/maml/dsl/mamldata")) {
			EPackage.Registry.INSTANCE.put("http://de/wwu/maml/dsl/mamldata", de.wwu.maml.dsl.mamldata.MamldataPackage.eINSTANCE);
		}
		if (!EPackage.Registry.INSTANCE.containsKey("http://de/wwu/maml/dsl/mamlgui")) {
			EPackage.Registry.INSTANCE.put("http://de/wwu/maml/dsl/mamlgui", de.wwu.maml.dsl.mamlgui.MamlguiPackage.eINSTANCE);
		}
		if (!EPackage.Registry.INSTANCE.containsKey("http://www.wwu.de/md2/framework/MD2")) {
			EPackage.Registry.INSTANCE.put("http://www.wwu.de/md2/framework/MD2", MD2Package.eINSTANCE);
		}	
	}

	public static void md2ToXmi(String inputUri, String outputUri) {
		init();

		// Source
		Injector injector = new MD2StandaloneSetup().createInjectorAndDoEMFRegistration();
		XtextResourceSet resourceSetXtext = injector.getInstance(XtextResourceSet.class);
		resourceSetXtext.addLoadOption(XtextResource.OPTION_RESOLVE_ALL, Boolean.TRUE);
		Resource resourceMd2 = resourceSetXtext.getResource(URI.createURI(inputUri), true);

		// Create new target file
		ResourceSet resourceSet = new ResourceSetImpl();
		Resource resourceXmi = resourceSet.createResource(URI.createURI(outputUri));

		// Copy content
		List<EObject> outObjects = resourceMd2.getContents();
		resourceXmi.getContents().addAll(outObjects);

		try {
			Map<String, String> options = new HashMap<String, String>();
			options.put(XMLResource.OPTION_ENCODING, "UTF-8");

			resourceXmi.save(options);
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public static void XmiToMd2(Resource inputResource, String outputPath, String projectName) {
		init();

		// Create new target file
		Injector injector = new MD2StandaloneSetup().createInjectorAndDoEMFRegistration();
		XtextResourceSet resourceSet = injector.getInstance(XtextResourceSet.class);
		resourceSet.addLoadOption(XtextResource.OPTION_RESOLVE_ALL, Boolean.TRUE);
		
		// Preparation for serialization needs some shifting: Only first MD2Model in a resource is persisted 
		// but all others need to be present to resolve cross references!! 
		
		// Copy content: Model layer
		Resource resourceMd2M = resourceSet.createResource(URI.createFileURI(outputPath + "/models/" + projectName + "Model.md2"));
		resourceMd2M.getContents().addAll(EcoreUtil2.copyAll(inputResource.getContents()));
		int modelIndex = resourceMd2M.getContents().indexOf(ResourceHelper.getMD2ModelContainer(resourceMd2M));
		EObject model = resourceMd2M.getContents().remove(modelIndex);
		resourceMd2M.getContents().add(0, model);	
		
		// Copy content: Controller layer
		Resource resourceMd2V = resourceSet.createResource(URI.createFileURI(outputPath + "/views/" + projectName + "View.md2"));
		resourceMd2V.getContents().addAll(EcoreUtil2.copyAll(inputResource.getContents()));
		int viewIndex = resourceMd2V.getContents().indexOf(ResourceHelper.getMD2ViewContainer(resourceMd2V));
		EObject view = resourceMd2V.getContents().remove(viewIndex);
		resourceMd2V.getContents().add(0, view);

		// Copy and shift content: Controller layer
		Resource resourceMd2C = resourceSet.createResource(URI.createFileURI(outputPath + "/controllers/" + projectName + "Controller.md2"));
		resourceMd2C.getContents().addAll(EcoreUtil2.copyAll(inputResource.getContents()));
		int controllerIndex = resourceMd2C.getContents().indexOf(ResourceHelper.getMD2ControllerContainer(resourceMd2C));
		EObject controller = resourceMd2C.getContents().remove(controllerIndex);
		resourceMd2C.getContents().add(0, controller);
		
		// Copy content: Controller layer
		Resource resourceMd2W = resourceSet.createResource(URI.createFileURI(outputPath + "/workflows/" + projectName + "Workflow.md2"));
		resourceMd2W.getContents().addAll(EcoreUtil2.copyAll(inputResource.getContents()));
		int workflowIndex = resourceMd2W.getContents().indexOf(ResourceHelper.getMD2WorkflowContainer(resourceMd2W));
		EObject workflow = resourceMd2W.getContents().remove(workflowIndex);
		resourceMd2W.getContents().add(0, workflow);				
		
		// Validate model before serialization
		System.out.println("Performing validation...");
		IResourceValidator validator = ((XtextResource) resourceMd2M).getResourceServiceProvider().getResourceValidator();
		List<Issue> issues = validator.validate(resourceMd2M, CheckMode.ALL, CancelIndicator.NullImpl);
		for(Issue issue : issues) {
			System.out.println(issue.getMessage());
		}
		
		// Save MD2 models
		System.out.println("Saving generated MD2 models...");
		
		try {
			resourceMd2M.save(Collections.emptyMap());
			resourceMd2V.save(Collections.emptyMap());
			resourceMd2C.save(Collections.emptyMap());
			resourceMd2W.save(Collections.emptyMap());
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}

