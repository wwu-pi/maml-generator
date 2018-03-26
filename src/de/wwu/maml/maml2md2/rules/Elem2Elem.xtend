package de.wwu.maml.maml2md2.rules;

import de.wwu.maml.dsl.maml.MamlFactory
import de.wwu.maml.dsl.maml.MamlPackage
import de.wwu.maml.dsl.mamlgui.MamlguiPackage
import de.wwu.maml.maml2md2.correspondence.maml2md2.Corr
import de.wwu.maml.maml2md2.correspondence.maml2md2.Maml2md2Factory
import de.wwu.maml.maml2md2.correspondence.maml2md2.Transformation
import de.wwu.md2.framework.mD2.MD2Factory
import de.wwu.md2.framework.mD2.MD2Package
import java.util.List
import java.util.Map
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.ResourceSet
import de.wwu.maml.dsl.mamldata.MamldataPackage
import de.wwu.maml.maml2md2.rules.view.Model2View
import de.wwu.md2.framework.mD2.View
import de.wwu.maml.maml2md2.rules.model.Model2Model
import de.wwu.md2.framework.mD2.Model
import de.wwu.maml.maml2md2.rules.controller.Model2Controller
import de.wwu.md2.framework.mD2.Controller
import de.wwu.md2.framework.mD2.Workflow
import de.wwu.maml.maml2md2.rules.workflow.Model2Workflow
import static extension de.wwu.maml.maml2md2.util.MamlHelper.*

abstract class Elem2Elem {
	
	protected ResourceSet sourceModel
	protected ResourceSet targetModel
	protected Resource corrModel
	
	protected val sourceFactory = MamlFactory::eINSTANCE
	protected val targetFactory = MD2Factory::eINSTANCE
	protected val corrFactory = Maml2md2Factory::eINSTANCE
	protected val sourcePackage = MamlPackage::eINSTANCE
	protected val targetPackage = MD2Package::eINSTANCE
	
	protected static Map<EObject, List<Corr>> elementsToCorr = newHashMap
	
	protected Map<EObject, String> uniqueObjectNames = newHashMap
	
	new(ResourceSet src, ResourceSet trgt, Resource corr) {
		sourceModel = src
		targetModel = trgt
		corrModel = corr
	}
	
	abstract def void sourceToTarget();
	
	abstract def void targetToSource();
	
	def getCorrModelElem(EObject obj, String description) {
		elementsToCorr.get(obj)?.filter[it.desc == description] ?: emptyList
	}
	
	def putCorrModelElement(EObject obj, Corr corr){
		val existing = elementsToCorr.get(obj) ?: newArrayList
		existing.add(corr)
		
		elementsToCorr.put(obj, existing)
	}

	def getOrCreateCorrModelElement(EObject obj, String description) {
		var Corr corr = obj.getCorrModelElem(description)?.head
		if (corr === null) {
			corr = corrFactory.createBasicElem => [
				if (obj.eClass.EPackage instanceof MamlPackage || obj.eClass.EPackage instanceof MamlguiPackage || obj.eClass.EPackage instanceof MamldataPackage)
					sourceElement = obj
				if (obj.eClass.EPackage instanceof MD2Package)
					targetElement = obj
				desc = description
			]
			(corrModel.contents.get(0) as Transformation).correspondences += corr
			if(corr.sourceElement !== null) {
				putCorrModelElement(corr.sourceElement, corr)
			}
			if(corr.targetElement !== null) {
				putCorrModelElement(corr.targetElement, corr)
			}
		}
		return corr
	}
	
	def createSourceElement(EClass clazz) {
		sourceFactory.create(clazz)
	}
	
	def createTargetElement(EClass clazz) {
		targetFactory.create(clazz)
	}
	
	def getOrCreateSourceElem(Corr corr, EClass clazz) {
		var EObject source  = corr.sourceElement
		if (corr.sourceElement === null){
			source = createSourceElement(clazz)
			corr.sourceElement = source
			putCorrModelElement(corr.sourceElement, corr)
		}
		return source
	}
	
	def findOrCreateSourceElemOfType(Corr corr, EClass clazz) {
		var existingElement = elementsToCorr.keySet.filter[it.eClass == clazz]?.head
		if(existingElement === null){
			existingElement = getOrCreateSourceElem(corr, clazz)
		} else {
			corr.sourceElement = existingElement
		}
		return existingElement
	}

	def getOrCreateTargetElem(Corr corr, EClass clazz) {
		var EObject target = corr.targetElement 
		if (target === null) {
			target = createTargetElement(clazz)
			corr.targetElement = target
			putCorrModelElement(corr.targetElement, corr)
		}
		return target
	}
	
	def findOrCreateTargetElemOfType(Corr corr, EClass clazz) {
		var existingElement = elementsToCorr.keySet.filter[it.eClass == clazz]?.head
		if(existingElement === null){
			existingElement = getOrCreateTargetElem(corr, clazz)
		} else {
			corr.targetElement = existingElement
		}
		return existingElement
	}
	
	def resolveElement(EClass clazz, String ruleId){
		return elementsToCorr.keySet.filter[it.eClass == clazz]?.filter[
			candidate | elementsToCorr.get(candidate).filter[it.desc == ruleId].size > 0
		]?.head
	}
	
	def getMD2ModelContent(){
		(resolveElement(targetPackage.model, Model2Model.ruleID) as Model)?.modelElements
	}
	
	def getMD2ViewContent(){
		(resolveElement(targetPackage.view, Model2View.ruleID) as View)?.viewElements
	}
	
	def getMD2ControllerContent(){
		(resolveElement(targetPackage.controller, Model2Controller.ruleID) as Controller)?.controllerElements
	}
	
	def getMD2Workflow(){
		(resolveElement(targetPackage.workflow, Model2Workflow.ruleID) as Workflow)
	}
	
	def toUniqueName(EObject elem, String name, int maxLength){
		val shortName = name.allowedAttributeName.maxLength(maxLength)
		return elem.toUniqueName(shortName)
	}
	
	def toUniqueName(EObject elem, String qualifiedName){
		val allowedName = qualifiedName.pathWithoutLastSegment + qualifiedName.lastSegment.allowedAttributeName
		
		if(!uniqueObjectNames.containsKey(elem)) {
			// Ensure a new object has a unique name using suffix
			var suffix = 0
			while(uniqueObjectNames.values.contains(allowedName + if(suffix == 0) "" else suffix)){
				suffix++
			}
			uniqueObjectNames.put(elem, allowedName + if(suffix == 0) "" else suffix)
		}
		return uniqueObjectNames.get(elem).lastSegment
	}
}