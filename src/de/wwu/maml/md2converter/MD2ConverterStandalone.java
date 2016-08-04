package de.wwu.maml.md2converter;

import java.io.OutputStreamWriter;
import java.util.ArrayList;
import java.util.Iterator;

import org.eclipse.emf.common.util.BasicEList;
import org.eclipse.emf.common.util.Diagnostic;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.resource.XtextResourceSet;
import org.eclipse.m2m.qvt.oml.BasicModelExtent;
import org.eclipse.m2m.qvt.oml.ExecutionContextImpl;
import org.eclipse.m2m.qvt.oml.ExecutionDiagnostic;
import org.eclipse.m2m.qvt.oml.ModelExtent;
import org.eclipse.m2m.qvt.oml.TransformationExecutor;
import org.eclipse.m2m.qvt.oml.util.Log;
import org.eclipse.m2m.qvt.oml.util.WriterLog;

import com.google.inject.Injector;

import de.wwu.md2.framework.MD2StandaloneSetup;
import de.wwu.md2.framework.mD2.Controller;
import de.wwu.md2.framework.mD2.MD2Factory;
import de.wwu.md2.framework.mD2.MD2ModelLayer;
import de.wwu.md2.framework.mD2.Model;
import de.wwu.md2.framework.mD2.View;
import de.wwu.md2.framework.mD2.Workflow;
import md2dot0.Md2dot0Factory;
import md2dot0.UseCase;

public class MD2ConverterStandalone {

	private static final String DEFAULT_PROJECT_NAME = "mamlProject";

	public static void main(String[] args) {
		// Register Xtext Resource Factory
		XmiToMd2Converter.init();

		Injector injector = new MD2StandaloneSetup().createInjectorAndDoEMFRegistration();
		XtextResourceSet resourceSetXtext = injector.getInstance(XtextResourceSet.class);
		resourceSetXtext.addLoadOption(XtextResource.OPTION_RESOLVE_ALL, Boolean.TRUE);

		// Define the common MD2Root element
		md2dot0.Model modelRoot = Md2dot0Factory.eINSTANCE.createModel();
		EList<EObject> allObjects = new BasicEList<EObject>();
		allObjects.add(modelRoot);

		// Define the transformation input
		// TODO crawl folders to find all .maml files
		ResourceSet resourceSet = new ResourceSetImpl();
		ArrayList<URI> modelSources = new ArrayList<URI>();
		modelSources.add(URI.createURI("platform:/resource/de.wwu.maml/resources/SimpleExample.md2dot0"));

		for (URI modelSource : modelSources) {
			Resource inResource = resourceSet.getResource(modelSource, true);

			// Add to common model root
			if (inResource.getContents() == null || inResource.getContents().size() == 0) {
				System.out.println("No content in model: " + modelSource.toPlatformString(true));
				continue;
			}

			EObject useCaseRoot = EcoreUtil.getRootContainer(inResource.getContents().get(0));
			if (useCaseRoot instanceof UseCase) {
				// Add use case to model root
				modelRoot.getUseCases().add((UseCase) useCaseRoot);
				// Add all contained elements
				Iterator<EObject> iter = modelRoot.eAllContents();
				while (iter.hasNext()) {
					allObjects.add(iter.next());
				}
			}
		}

		// Perform four individual transformations
		transformMamlToMd2(allObjects, MD2Factory.eINSTANCE.createModel());
		transformMamlToMd2(allObjects, MD2Factory.eINSTANCE.createController());
		transformMamlToMd2(allObjects, MD2Factory.eINSTANCE.createView());
		transformMamlToMd2(allObjects, MD2Factory.eINSTANCE.createWorkflow());

		System.out.println("Done");
	}

	public static void transformMamlToMd2(EList<EObject> modelObjects, MD2ModelLayer layer) {
		if (modelObjects == null || modelObjects.size() == 0) {
			throw new RuntimeException("No model objects to transform!");
		} else if(layer == null) {
			throw new RuntimeException("No MD2 layer to transform to!");
		} else {
			System.out.println("Start transformation for " + layer.getClass().getSimpleName() + " layer...");
		}

		// create the input extent with its initial contents
		ModelExtent input = new BasicModelExtent(modelObjects);
		// create an empty extent to catch the output
		ModelExtent output = new BasicModelExtent();

		// setup the execution environment details
		// -> configuration properties, logger, monitor object etc.
		ExecutionContextImpl context = new ExecutionContextImpl();
		context.setConfigProperty("keepModeling", true);
		
		// Activate logging
		OutputStreamWriter outStream = new OutputStreamWriter(System.out);
		Log log = new WriterLog(outStream);
		context.setLog(log);

		// Human readable model project name
		String projectName = DEFAULT_PROJECT_NAME;
		if (((md2dot0.Model) EcoreUtil.getRootContainer(modelObjects.get(0))).getProjectName() != null) {
			projectName = ((md2dot0.Model) EcoreUtil.getRootContainer(modelObjects.get(0))).getProjectName();
		}

		// run the transformation assigned to the executor with the given
		// input and output and execution context -> ChangeTheWorld(in, out)
		ExecutionDiagnostic result = null;
		String outputFile = "platform:/resource/de.wwu.maml/src-gen/";
		if (layer instanceof Model) {
			URI transformationURI = URI.createURI(
					"platform:/resource/de.wwu.maml/src/de/wwu/maml/md2converter/transformations/Md2ViewLayer.qvto");

			TransformationExecutor executor = new TransformationExecutor(transformationURI);
			result = executor.execute(context, input, output);
			outputFile += projectName + "/models/" + projectName + "Model.md2";

		} else if (layer instanceof View) {
			URI transformationURI = URI.createURI(
					"platform:/resource/de.wwu.maml/src/de/wwu/maml/md2converter/transformations/Md2ViewLayer.qvto");

			TransformationExecutor executor = new TransformationExecutor(transformationURI);
			result = executor.execute(context, input, output);
			outputFile += projectName + "/views/" + projectName + "View.md2";

		} else if (layer instanceof Controller) {
			URI transformationURI = URI.createURI(
					"platform:/resource/de.wwu.maml/src/de/wwu/maml/md2converter/transformations/Md2ControllerLayer.qvto");

			TransformationExecutor executor = new TransformationExecutor(transformationURI);
			result = executor.execute(context, input, output);
			outputFile += projectName + "/controllers/" + projectName + "Controller.md2";

		} else if (layer instanceof Workflow) {
			URI transformationURI = URI.createURI(
					"platform:/resource/de.wwu.maml/src/de/wwu/maml/md2converter/transformations/Md2WorkflowLayer.qvto");

			TransformationExecutor executor = new TransformationExecutor(transformationURI);
			result = executor.execute(context, input, output);
			outputFile += projectName + "/workflows/" + projectName + "Workflow.md2";

		} else {
			throw new RuntimeException("Unsupported MD2 layer encountered!");
		}

		// check the result for success
		if (result != null && result.getSeverity() == Diagnostic.OK) {
			// the output objects got captured in the output extent
			XmiToMd2Converter.writeToMd2(output.getContents(), outputFile);
		} else {
			throw new RuntimeException("Transformation failed. " + result.toString());
		}
	}
}
