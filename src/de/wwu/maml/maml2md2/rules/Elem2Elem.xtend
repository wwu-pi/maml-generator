package de.wwu.maml.maml2md2.rules;

import org.eclipse.emf.ecore.resource.Resource
import java.util.List
import de.wwu.maml.maml2md2.correspondence.maml2md2.Corr
import de.wwu.maml.maml2md2.correspondence.maml2md2.Transformation
import de.wwu.maml.maml2md2.correspondence.maml2md2.Maml2md2Package
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.util.EcoreUtil
import java.util.Map

abstract class Elem2Elem {
	
	protected Resource sourceModel
	protected Resource targetModel
	protected Resource corrModel
	
	protected val sourceFactory = de.wwu.maml.dsl.maml.MamlFactory::eINSTANCE
	protected val targetFactory = de.wwu.md2.framework.mD2.MD2Factory::eINSTANCE
	protected val corrFactory = de.wwu.maml.maml2md2.correspondence.maml2md2.Maml2md2Factory::eINSTANCE
	protected val sourcePackage = de.wwu.maml.dsl.maml.MamlPackage::eINSTANCE
	protected val targetPackage = de.wwu.md2.framework.mD2.MD2Package::eINSTANCE
	
	protected var String ruleID = ""
	
	protected static Map<String, Corr> elementsToCorr = newHashMap
	protected static Map<String, EObject> hashToElements = newHashMap
	
	new(Resource src, Resource trgt, Resource corr) {
		sourceModel = src
		targetModel = trgt
		corrModel = corr
//		ruleID = ruleIdentifier;
//		(corrModel.contents.get(0) as Transformation).correspondences.forEach[c | 
//			elementsToCorr.put(c.sourceElement.hashCode + ".", c)
//			elementsToCorr.put(c.targetElement.hashCode + ".", c)
//		]
	}
	
	abstract def void sourceToTarget();
	
	abstract def void targetToSource();
	
	def getCorrModelElem(EObject obj, String description) {
		elementsToCorr.get(obj.hashCode + "." + description)
	}

	def getOrCreateCorrModelElement(EObject obj, String description) {
		var Corr corr = obj.getCorrModelElem(description)
		if (corr === null) {
			corr = corrFactory.createBasicElem => [
				if (obj.eClass.EPackage instanceof de.wwu.maml.dsl.maml.MamlPackage)
					sourceElement = obj
				if (obj.eClass.EPackage instanceof de.wwu.md2.framework.mD2.MD2Package)
					targetElement = obj
				desc = description
			]
			(corrModel.contents.get(0) as Transformation).correspondences += corr
			if(corr.sourceElement !== null) {
				elementsToCorr.put(corr.sourceElement.hashCode + "." + ruleID, corr)
				hashToElements.put(corr.sourceElement.hashCode + "." + ruleID, corr.sourceElement)
			}
			if(corr.targetElement !== null) {
				elementsToCorr.put(corr.targetElement.hashCode + "." + ruleID, corr)
				hashToElements.put(corr.targetElement.hashCode + "." + ruleID, corr.targetElement)
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
			elementsToCorr.put(corr.sourceElement + "." + ruleID, corr)
			hashToElements.put(corr.sourceElement.hashCode + "." + ruleID, corr.sourceElement)
		}
		return source
	}
	
	def findOrCreateSourceElemOfType(Corr corr, EClass clazz) {
		var existingElement = hashToElements.values.filter[it.eClass == clazz]?.head
		if(existingElement === null){
			existingElement = getOrCreateSourceElem(corr, clazz)
		}
		return existingElement
	}

	def getOrCreateTargetElem(Corr corr, EClass clazz) {
		var EObject target = corr.targetElement 
		if (target === null) {
			target = createTargetElement(clazz)
			corr.targetElement = target
			elementsToCorr.put(corr.targetElement + "." + ruleID, corr)
			hashToElements.put(corr.targetElement.hashCode + "." + ruleID, corr.targetElement)
		}
		return target
	}
	
	
}