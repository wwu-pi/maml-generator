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
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.resource.XtextResourceSet;
import com.google.inject.Injector;

import de.wwu.md2.framework.MD2StandaloneSetup;
import de.wwu.md2.framework.mD2.MD2Package;

public class XmiToMd2Converter {

//	public static void main(String[] args) {
//		md2ToXmi("platform:/resource/de.wwu.maml/resources/input.md2",
//				"platform:/resource/de.wwu.maml/resources/output.xmi");
//
//		XmiToMd2("platform:/resource/de.wwu.maml/resources/input.xmi",
//				"platform:/resource/de.wwu.maml/resources/output.md2");
//	}

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

	public static void XmiToMd2(String inputUri, String outputUri) {
		init();

		// Source
		ResourceSet resourceSet = new ResourceSetImpl();
		Resource resourceXmi = resourceSet.getResource(URI.createURI(inputUri), true);
		
		writeToMd2(resourceXmi.getContents(), outputUri);
	}
	
	public static void XmiToMd2(Resource inputResource, String outputUri) {
		init();

		writeToMd2(inputResource.getContents(), outputUri);
	}
	
	public static void writeToMd2(List<EObject> output, String outputUri){
		init();

		// Create new target file
		Injector injector = new MD2StandaloneSetup().createInjectorAndDoEMFRegistration();
		XtextResourceSet resourceSet = injector.getInstance(XtextResourceSet.class);
		resourceSet.addLoadOption(XtextResource.OPTION_RESOLVE_ALL, Boolean.TRUE);
		Resource resourceMd2 = resourceSet.createResource(URI.createFileURI(outputUri));

		// Copy content
		resourceMd2.getContents().addAll(output);
		
		// TODO check that at least one element is contained

		try {
			resourceMd2.save(Collections.emptyMap());
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}
