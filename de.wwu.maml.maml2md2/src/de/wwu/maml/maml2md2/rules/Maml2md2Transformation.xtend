package de.wwu.maml.maml2md2.rules;

import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.emf.ecore.EObject
import de.wwu.maml.maml2md2.correspondence.maml2md2.Corr
import java.util.ArrayList
import java.util.List
import de.wwu.maml.maml2md2.rules.model.Model2Model
import de.wwu.maml.maml2md2.rules.view.Model2View
import java.util.Map
import de.wwu.maml.maml2md2.rules.controller.Model2Controller
import de.wwu.maml.maml2md2.rules.workflow.Model2Workflow
import de.wwu.maml.maml2md2.correspondence.maml2md2.Transformation
import de.wwu.maml.maml2md2.rules.model.DataType2ModelElement
import de.wwu.maml.maml2md2.rules.workflow.Role2App
import de.wwu.maml.maml2md2.rules.controller.ProcessElement2WorkflowElement
import de.wwu.maml.maml2md2.rules.view.ProcessElement2ViewFrame
import de.wwu.maml.maml2md2.rules.workflow.ProcessElement2WorkflowElementEntry
import de.wwu.maml.maml2md2.rules.view.Attribute2Attribute
import de.wwu.maml.maml2md2.rules.controller.DataSource2ContentProvider
import de.wwu.maml.dsl.maml.Model
import static extension de.wwu.maml.maml2md2.util.MamlHelper.*

public class Maml2md2Transformation {
	
	private ResourceSet sourceModel
	private ResourceSet targetModel
	private Resource corrModel
	
	public static String PACKAGE_NAME = "de.wwu.simpleApp"
	
	private List<Elem2Elem> rules = new ArrayList<Elem2Elem>();
	protected static Map<String, Corr> elementsToCorr = newHashMap
	
	new(URI source, URI target, URI correspondence) {
		sourceModel = new ResourceSetImpl();
		sourceModel.resources.add(new ResourceSetImpl().getResource(source, true))
		
		targetModel = new ResourceSetImpl();
		targetModel.resources.add(new ResourceSetImpl().getResource(target, true))
		
		corrModel = new ResourceSetImpl().getResource(correspondence, true)
		
		if (corrModel.contents.size == 0) {
			corrModel.contents.add(de.wwu.maml.maml2md2.correspondence.maml2md2.Maml2md2Factory.eINSTANCE.createTransformation)	
		}

		// TODO: add your rules in the proper order to the 'rules' List
		addRules		
	}
	
	new(ResourceSet source, ResourceSet target, Resource correspondence) {
		sourceModel = source
		targetModel = target
		corrModel = correspondence
		
		if (corrModel.contents.size == 0) {
			corrModel.contents.add(de.wwu.maml.maml2md2.correspondence.maml2md2.Maml2md2Factory.eINSTANCE.createTransformation)	
		}
		
		// Set project name
		PACKAGE_NAME = (sourceModel.resources.get(0).getContents().get(0) as Model).projectName.allowedAttributeName
		
		addRules
	}
	
	def private void addRules() {
		// bottom up approach, create the root object of the Ecore model, then
		// start with the leaves
		rules.add(new Model2Model(sourceModel, targetModel, corrModel))
		rules.add(new Model2View(sourceModel, targetModel, corrModel))
		rules.add(new Model2Controller(sourceModel, targetModel, corrModel))
		rules.add(new Model2Workflow(sourceModel, targetModel, corrModel))
		
		// Model Layer transformations
		rules.add(new DataType2ModelElement(sourceModel, targetModel, corrModel))
		
		// View Layer transformation
		rules.add(new ProcessElement2ViewFrame(sourceModel, targetModel, corrModel))
		rules.add(new Attribute2Attribute(sourceModel, targetModel, corrModel))
		
		// Controller Layer transformations
		rules.add(new DataSource2ContentProvider(sourceModel, targetModel, corrModel))
		rules.add(new ProcessElement2WorkflowElement(sourceModel, targetModel, corrModel))
		
		// Workflow layer transformations
		rules.add(new Role2App(sourceModel, targetModel, corrModel))
		rules.add(new ProcessElement2WorkflowElementEntry(sourceModel, targetModel, corrModel))
		
	}
	
	def void sourceToTarget() {
		if (sourceModel.resources.map[it.contents.size].reduce[r1, r2| r1 + r2] > 0)
		for (Elem2Elem e : rules) {
			e.sourceToTarget()
		}
		
		// handle deletions
		deleteUnreferencedTargetElements
		
		logTransformations(corrModel)
	}
	
	def void targetToSource() {		
		if (targetModel.resources.map[it.contents.size].reduce[r1, r2| r1 + r2] > 0)
		for (Elem2Elem e: rules) {
			e.targetToSource()
		}
		
		// handle deletions
		deleteUnreferencedSourceElements
		
		logTransformations(corrModel)
	}
	
	def boolean checkCorrespondences() {
		true
	}
	
	def detectSourceDeletions() {
		corrModel.allContents.filter(typeof(Corr)).filter[ c |
			c.sourceElement === null
		]
	}
		
	def detectTargetDeletions() {
		corrModel.allContents.filter(typeof(Corr)).filter[ c |
			c.targetElement === null 
		]
	}
	
	def deleteUnreferencedTargetElements(){
		val List<EObject> deletionList = newArrayList; 
		
		detectSourceDeletions().forEach[c |
			// TODO: add handling of contained and referenced Elements here if appropriate			
			// end
			deletionList += c.targetElement
			deletionList += c
		]
		deletionList.forEach[e | EcoreUtil.delete(e, true)]
	}
	
	def deleteUnreferencedSourceElements(){
		val List<EObject> deletionList = newArrayList; 
		
		detectTargetDeletions().forEach[c |
			// TODO: add handling of contained and referenced Elements here if appropriate
			
			// end
			deletionList += c.sourceElement
			deletionList += c
		]
		deletionList.forEach[e | EcoreUtil.delete(e, true)]
	}
	
	def void logTransformations(Resource corrModel){
		val groupedList = corrModel.contents.filter(Transformation).get(0).correspondences.filter(Corr).groupBy[it.sourceElement]
		
		for(key : groupedList.keySet) {
			println("Correspondence: " + key)
			for(value : groupedList.get(key)){
				println("    | " + value.desc + " | " + value.targetElement)
			}
		}
	}
}