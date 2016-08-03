package de.wwu.maml.md2converter;

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

public class XMIConverter {

	public static void main(String[] args) {

		//md2ToXmi("platform:/resource/de.wwu.maml/resources/input.md2",
		//		"platform:/resource/de.wwu.maml/resources/output.xmi");

		XmiToMd2("platform:/resource/de.wwu.maml/resources/input.xmi",
				"platform:/resource/de.wwu.maml/resources/output.md2");
		
		System.out.println("Done");
	}

	public static void init() {
		// Register Xtext Resource Factory
		new org.eclipse.emf.mwe.utils.StandaloneSetup().setPlatformUri("../");

		// Register MAML and MD2 meta models
		if (!EPackage.Registry.INSTANCE.containsKey("http://de/wwu/md2dot0")) {
			EPackage.Registry.INSTANCE.put("http://de/wwu/md2dot0", md2dot0.Md2dot0Package.eINSTANCE);
		}
		if (!EPackage.Registry.INSTANCE.containsKey("http://de/wwu/md2dot0data")) {
			EPackage.Registry.INSTANCE.put("http://de/wwu/md2dot0data", md2dot0data.Md2dot0dataPackage.eINSTANCE);
		}
		if (!EPackage.Registry.INSTANCE.containsKey("http://de/wwu/md2dot0gui")) {
			EPackage.Registry.INSTANCE.put("http://de/wwu/md2dot0gui", md2dot0gui.Md2dot0guiPackage.eINSTANCE);
		}
		if (!EPackage.Registry.INSTANCE.containsKey("http://www.wwu.de/md2/framework/MD2")) {
			EPackage.Registry.INSTANCE.put("http://www.wwu.de/md2/framework/MD2", MD2Package.eINSTANCE);
		}	
	}

	public static void md2ToXmi(String inputUri, String outputUri) {
		init();

		// Source
		Injector injector = new MD2StandaloneSetup().createInjectorAndDoEMFRegistration();
		XtextResourceSet resourceSet2 = injector.getInstance(XtextResourceSet.class);
		resourceSet2.addLoadOption(XtextResource.OPTION_RESOLVE_ALL, Boolean.TRUE);
		Resource resourceMd2 = resourceSet2.getResource(URI.createURI(inputUri), true);

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
		
		// Create new target file
		Injector injector = new MD2StandaloneSetup().createInjectorAndDoEMFRegistration();
		XtextResourceSet resourceSet2 = injector.getInstance(XtextResourceSet.class);
		resourceSet2.addLoadOption(XtextResource.OPTION_RESOLVE_ALL, Boolean.TRUE);
		Resource resourceMd2 = resourceSet2.createResource(URI.createURI(outputUri));

		// Copy content
		List<EObject> outObjects = resourceXmi.getContents();
		resourceMd2.getContents().addAll(outObjects);

		try {
			resourceMd2.save(Collections.emptyMap());
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}
