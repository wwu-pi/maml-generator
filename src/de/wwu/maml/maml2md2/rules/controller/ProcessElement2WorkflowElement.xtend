package de.wwu.maml.maml2md2.rules.controller

import de.wwu.maml.dsl.maml.InteractionProcessElement
import de.wwu.maml.maml2md2.rules.Elem2Elem
import de.wwu.maml.maml2md2.rules.view.ProcessElement2ViewFrame
import de.wwu.md2.framework.mD2.AbstractViewFrameRef
import de.wwu.md2.framework.mD2.Action
import de.wwu.md2.framework.mD2.Controller
import de.wwu.md2.framework.mD2.CustomAction
import de.wwu.md2.framework.mD2.ProcessChain
import de.wwu.md2.framework.mD2.ProcessChainStep
import de.wwu.md2.framework.mD2.ViewFrame
import de.wwu.md2.framework.mD2.WorkflowElement
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.ResourceSet

import static extension de.wwu.maml.maml2md2.util.MamlHelper.*
import static extension de.wwu.maml.maml2md2.util.ResourceHelper.*

class ProcessElement2WorkflowElement extends Elem2Elem {
	
	public static final String ruleID = "ProcessElement->WorkflowElement"
	public static final String ruleIDinitAction = ruleID + "[initAction]"
	//public static final String ruleIDworkflowEvent = "ProcessElement->WorkflowEvent"
	
	new(ResourceSet src, ResourceSet trgt, Resource corr) {
		super(src, trgt, corr)
	}
	 
	/* 
	 * Dependencies:
	 * - ViewFrame
	 */
	override def sourceToTarget() {
		sourceModel.allContents.filter(typeof(InteractionProcessElement))
			.forEach[src |
				// Create default process chain
				val defaultPc = createTargetElement(targetPackage.processChain) as ProcessChain
				defaultPc.name = "defaultProcessChain"
				
				val pcStep = createTargetElement(targetPackage.processChainStep) as ProcessChainStep
				val viewRef = createTargetElement(targetPackage.abstractViewFrameRef) as AbstractViewFrameRef
				viewRef.ref = resolveElement(targetPackage.viewFrame, ProcessElement2ViewFrame.ruleID) as ViewFrame
				pcStep.view = viewRef
				
				defaultPc.processChainSteps.add(pcStep)
				
				// Create workflow element
				val corr = src.getOrCreateCorrModelElement(ruleID)
				val wfe = corr.getOrCreateTargetElem(targetPackage.workflowElement) as WorkflowElement
				wfe.name = src.workflowElementName
				wfe.processChain.add(defaultPc)
				wfe.defaultProcessChain = defaultPc
				
				val initAction = src.createMd2InitAction()
				wfe.actions.add(initAction)
				wfe.initActions.add(initAction)
				
				// Attach to container
				val container = resolveElement(targetPackage.controller, Model2Controller.ruleID) as Controller
				(container as Controller)?.controllerElements?.add(wfe)
				
				MD2ControllerContent.add(wfe)
			]
	}
	
	override def targetToSource() {
//		targetModel.allContents.filter(typeof(de.wwu.md2.framework.mD2.Model))
//			.forEach[m |
//				val corr = m.getOrCreateCorrModelElement(ruleID)
//				val source = corr.findOrCreateSourceElemOfType(sourcePackage.model)
//				sourceModel.MAMLResource.contents += source
//			]
	}
	
	def Action createMd2InitAction(InteractionProcessElement src){
		// TODO dummy
		val corr = src.getOrCreateCorrModelElement(ruleIDinitAction)
		val action = corr.getOrCreateTargetElem(targetPackage.customAction) as CustomAction
		
		return action
	}
}