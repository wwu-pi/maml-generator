package de.wwu.maml.md2converter;

import org.eclipse.emf.common.util.Diagnostic;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.resource.XtextResourceSet;
import org.eclipse.m2m.qvt.oml.BasicModelExtent;
import org.eclipse.m2m.qvt.oml.ExecutionContextImpl;
import org.eclipse.m2m.qvt.oml.ExecutionDiagnostic;
import org.eclipse.m2m.qvt.oml.ModelExtent;
import org.eclipse.m2m.qvt.oml.TransformationExecutor;

import com.google.inject.Injector;

import de.wwu.md2.framework.MD2StandaloneSetup;

public class MD2ConverterStandalone {
	
	public static void main(String[] args){
		// Register Xtext Resource Factory
		new org.eclipse.emf.mwe.utils.StandaloneSetup().setPlatformUri("../");
		Injector injector = new MD2StandaloneSetup().createInjectorAndDoEMFRegistration();
		XtextResourceSet resourceSet2 = injector.getInstance(XtextResourceSet.class);
		resourceSet2.addLoadOption(XtextResource.OPTION_RESOLVE_ALL, Boolean.TRUE);
		
		// Refer to an existing transformation via URI
		URI transformationURI = URI.createURI("platform:/resource/de.wwu.maml/src/de/wwu/maml/md2converter/transformations/Md2Transformation.qvto");
		// create executor for the given transformation
		TransformationExecutor executor = new TransformationExecutor(transformationURI);

		XmiToMd2Converter.init();
		
		// define the transformation input
		// Remark: we take the objects from a resource, however
		// a list of arbitrary in-memory EObjects may be passed
		ResourceSet resourceSet = new ResourceSetImpl();
		Resource inResource = resourceSet.getResource(
				URI.createURI("platform:/resource/de.wwu.maml/resources/SimpleExample.md2dot0"), true);		
		EList<EObject> inObjects = inResource.getContents();

		// create the input extent with its initial contents
		ModelExtent input = new BasicModelExtent(inObjects);		
		// create an empty extent to catch the output
		ModelExtent output = new BasicModelExtent();

		// setup the execution environment details -> 
		// configuration properties, logger, monitor object etc.
		ExecutionContextImpl context = new ExecutionContextImpl();
		context.setConfigProperty("keepModeling", true);

		// run the transformation assigned to the executor with the given 
		// input and output and execution context -> ChangeTheWorld(in, out)
		// Remark: variable arguments count is supported
		ExecutionDiagnostic result = executor.execute(context, input, output);

		// check the result for success
		if(result.getSeverity() == Diagnostic.OK) {
			// the output objects got captured in the output extent
			XmiToMd2Converter.writeToMd2(output.getContents(), "platform:/resource/de.wwu.maml/resources/output.md2");
		} else {
			throw new RuntimeException("Transformation failed. " + result.toString());
		}
		System.out.println("Done");
	}
}
